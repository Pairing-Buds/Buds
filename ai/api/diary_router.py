from fastapi import APIRouter, HTTPException
from datetime import datetime
from pydantic import BaseModel
from typing import Optional
from db.mysql import mysql_db
from db.chroma import chroma_db
from core.chatbot import chatbot

router = APIRouter()


class DiarySaveRequest(BaseModel):
    user_id: int
    save: bool
    emotion_diary: Optional[str] = None
    active_diary: Optional[str] = None


class DiarySaveResponse(BaseModel):
    success: bool
    message: str


@router.post("/diary/save", response_model=DiarySaveResponse)
async def save_diary(request: DiarySaveRequest):
    """
    사용자의 일기 저장 API

    오후 10시에 생성된 일기를 사용자가 저장하기로 결정했을 때 호출됩니다.
    """
    try:
        if request.save:
            now = datetime.now()

            # 감정 일기 저장
            if request.emotion_diary:
                mysql_db.execute(
                    """
                    INSERT INTO diaries (user_id, content, date, created_at, diary_type)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (request.user_id, request.emotion_diary, now, now, 'EMOTION')
                )

            # 행동 일기 저장
            if request.active_diary:
                mysql_db.execute(
                    """
                    INSERT INTO diaries (user_id, content, date, created_at, diary_type)
                    VALUES (%s, %s, %s, %s, %s)
                    """,
                    (request.user_id, request.active_diary, now, now, 'ACTIVE')
                )

            return DiarySaveResponse(
                success=True,
                message="일기가 성공적으로 저장되었습니다."
            )
        else:
            # 저장을 거부한 경우
            return DiarySaveResponse(
                success=True,
                message="일기 저장이 취소되었습니다."
            )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/diary/generate", response_model=dict)
async def generate_diary(user_id: int):
    """사용자의 채팅 기록을 바탕으로 일기를 생성하는 API"""
    try:
        # 오늘 날짜
        today = datetime.now().date().isoformat()

        # ChromaDB에서 사용자의 컬렉션 가져오기
        collection = chroma_db.get_or_create_collection(user_id)

        # 모든 대화 내용 가져오기
        # 참고: 실제로는 날짜 필터링이 필요할 수 있음
        results = collection.get()

        if not results or not results["documents"]:
            return {
                "success": False,
                "message": "채팅 기록이 없습니다."
            }

        # 대화 내용 정리
        conversations = []
        for i, doc in enumerate(results["documents"]):
            metadata = results["metadatas"][i]
            conversations.append({
                "text": doc,
                "type": metadata["type"]
            })

        # 대화 텍스트 생성
        chat_text = "\n".join([f"{'사용자' if conv['type'] == 'user' else '봇'}: {conv['text']}" for conv in conversations])

        # 감정 일기와 행동 일기 생성
        emotion_diary = chatbot.generate_emotion_diary(chat_text)
        active_diary = chatbot.generate_active_diary(chat_text)

        return {
            "success": True,
            "emotion_diary": emotion_diary,
            "active_diary": active_diary,
            "user_id": user_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))