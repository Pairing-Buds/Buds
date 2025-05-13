from fastapi import APIRouter, HTTPException
from ..core.emotion_classifier import EmotionClassifier
from pydantic import BaseModel
from typing import List

router = APIRouter()
classifier = EmotionClassifier()

class PredictionRequest(BaseModel):
    texts: List[str]

@router.post("/predict")
async def predict_endpoint(request: PredictionRequest):
    try:
        results = await classifier.predict(request.texts)
        return {"results": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
