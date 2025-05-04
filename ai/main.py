import logging
import sys
import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# 현재 디렉토리를 Python 패스에 추가
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# 환경 변수 로드
load_dotenv()

# 로깅 설정
logging.basicConfig(
    level=getattr(logging, os.getenv("LOG_LEVEL", "INFO")),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

# FastAPI 앱 초기화
app = FastAPI(title="AI 챗봇 API")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 라우터 및 WebSocket 설정
from api.routes import router
from api.websocket import websocket_endpoint

app.include_router(router)
app.add_websocket_route("/ws/{user_id}", websocket_endpoint)

# 기본 루트 엔드포인트
@app.get("/")
def read_root():
    """서버 상태 확인 엔드포인트"""
    from api.websocket import connection_manager
    return {
        "status": "active",
        "connections": len(connection_manager.active_connections)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)