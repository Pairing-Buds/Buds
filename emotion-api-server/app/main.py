# app/main.py (모니터링 추가)
from fastapi import FastAPI
from app.routers import predict
import torch

app = FastAPI()

@app.on_event("startup")
async def startup_event():
    # 서버 시작 시 모델 웜업
    test_text = ["서비스 초기화 중"]
    await predict.classifier.predict(test_text)

app.include_router(predict.router)

@app.get("/health")
def health_check():
    return {"status": "healthy", "gpu_available": torch.cuda.is_available()}
