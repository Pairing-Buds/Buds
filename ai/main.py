import logging
import sys
import os
import time
import uuid
import json
import socket
import threading
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI, Request, Response
from loguru import logger
from starlette.middleware.base import BaseHTTPMiddleware

# 현재 디렉토리를 Python 패스에 추가
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# 환경 변수 로드
dotenv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), '.env')
load_dotenv(dotenv_path=dotenv_path)

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from prometheus_fastapi_instrumentator import Instrumentator

# 로깅 설정
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler("app.log")
    ]
)


# 앱 수명 주기 관리를 위한 lifespan 이벤트 핸들러 정의
@asynccontextmanager
async def lifespan(app: FastAPI):
    # 앱 시작 시 실행 (startup)
    from api.diary import start_scheduler
    start_scheduler()
    logging.info("앱이 시작되었으며 일기 생성 스케줄러가 활성화되었습니다")

    yield  # 앱 실행 중

    # 앱 종료 시 실행 (shutdown)
    from api.diary import shutdown_scheduler
    shutdown_scheduler()
    logging.info("앱이 종료되며 일기 생성 스케줄러가 비활성화되었습니다")


# 로그 디렉토리 생성
os.makedirs("logs", exist_ok=True)


# Logstash로 로그를 전송하는 클래스
class LogstashSender:
    def __init__(self):
        self.host = os.environ.get("LOGSTASH_HOST", "docker-elk_logstash_1")
        self.port = int(os.environ.get("LOGSTASH_PORT", "5044"))
        self.lock = threading.Lock()
        self.socket = None
        self.connect()
        logger.info(f"Logstash 연결 설정: {self.host}:{self.port}")

    def connect(self):
        try:
            if self.socket:
                self.socket.close()
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.connect((self.host, self.port))
            logger.info(f"Logstash 연결 성공: {self.host}:{self.port}")
            return True
        except Exception as e:
            logger.error(f"Logstash 연결 실패: {str(e)}")
            self.socket = None
            return False

    def send(self, data):
        if not isinstance(data, dict):
            return False

        json_data = json.dumps(data) + "\n"

        with self.lock:
            try:
                if not self.socket and not self.connect():
                    return False
                self.socket.sendall(json_data.encode('utf-8'))
                return True
            except Exception as e:
                logger.error(f"Logstash 전송 실패: {str(e)}")
                self.socket = None
                return False


# 로거 설정
def setup_logging():
    # 기존 로거 설정 제거
    logger.remove()

    # 콘솔 로거 추가
    logger.add(sys.stdout, format="{time} | {level} | {message}", level="INFO")

    # 파일 로거 추가 (JSON 형식)
    logger.add(
        "logs/app.json",
        format="{time} | {level} | {message}",
        serialize=True,  # JSON 형식으로 직렬화
        rotation="10 MB",  # 파일 크기 제한
        retention="7 days",  # 보관 기간
        level="INFO"
    )

    return logger


# 로거 초기화
logger = setup_logging()

# 글로벌 로그스태시 전송 객체
logstash_sender = LogstashSender()


# API 로깅 미들웨어
class APILoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # 요청 ID 생성
        request_id = str(uuid.uuid4())

        # 시작 시간 기록
        start_time = time.time()

        # 요청 정보 추출
        path = request.url.path
        method = request.method
        client_host = request.client.host if request.client else "unknown"

        # 요청 시작 로그
        log_data = {
            "event": "api_request_start",
            "request_id": request_id,
            "method": method,
            "path": path,
            "client_ip": client_host,
            "service": "fastapi",
            "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z")
        }

        # 로그 기록 및 전송
        logger.info(json.dumps(log_data))
        logstash_sender.send(log_data)

        # 요청 처리
        try:
            response = await call_next(request)
            status_code = response.status_code

            # 성공 응답 로그
            process_time = (time.time() - start_time) * 1000
            log_data = {
                "event": "api_request_end",
                "request_id": request_id,
                "method": method,
                "path": path,
                "status_code": status_code,
                "process_time_ms": round(process_time, 2),
                "client_ip": client_host,
                "service": "fastapi",
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z")
            }

            # 로그 기록 및 전송
            logger.info(json.dumps(log_data))
            logstash_sender.send(log_data)

            return response
        except Exception as e:
            # 예외 발생 로그
            process_time = (time.time() - start_time) * 1000
            log_data = {
                "event": "api_request_error",
                "request_id": request_id,
                "method": method,
                "path": path,
                "error": str(e),
                "process_time_ms": round(process_time, 2),
                "client_ip": client_host,
                "service": "fastapi",
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%S%z")
            }

            # 로그 기록 및 전송
            logger.error(json.dumps(log_data))
            logstash_sender.send(log_data)
            raise


# FastAPI 앱 초기화 (lifespan 지정)
app = FastAPI(title="AI 챗봇 API", lifespan=lifespan)

# 미들웨어 등록
app.add_middleware(APILoggingMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 및 WebSocket 설정
from api.chat import router as chat_router
from api.websocket import websocket_endpoint

app.include_router(chat_router)

# Prometheus 메트릭 설정
Instrumentator().instrument(app).expose(app)


# WebSocket 엔드포인트 추가
@app.websocket("/ws/{user_id}")
async def websocket_route(websocket, user_id: int):
    await websocket_endpoint(websocket, user_id)


# 기본 루트 엔드포인트
@app.get("/")
def read_root():
    """서버 상태 확인 엔드포인트"""
    from api.websocket import connection_manager
    return {
        "status": "active",
        "connections": len(connection_manager.active_connections)
    }


# 수동으로 일기 생성을 트리거하는 엔드포인트 (개발 및 테스트용)
@app.post("/admin/generate-diaries")
async def trigger_diary_generation():
    """수동으로 일기 생성을 트리거하는 관리자 엔드포인트"""
    from api.diary import manual_generate_diaries
    await manual_generate_diaries()
    return {"status": "success", "message": "일기 생성이 수동으로 트리거되었습니다"}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)