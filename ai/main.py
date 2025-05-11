import logging
import sys
import os
from contextlib import asynccontextmanager
from dotenv import load_dotenv

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


# FastAPI 앱 초기화 (lifespan 지정)
app = FastAPI(title="AI 챗봇 API", lifespan=lifespan)

# CORS 설정
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