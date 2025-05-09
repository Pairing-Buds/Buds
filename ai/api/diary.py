from fastapi import APIRouter, HTTPException, Depends
from datetime import datetime
from db.chroma import chroma_db
from core.chatbot import chatbot
from core.jwt_auth import get_user_id_from_token

router = APIRouter()

@router.post("/diary/generate", response_model=dict)
async def generate_diary(
        user_id: int = Depends(get_user_id_from_token)
):
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
            "emotion_diary": emotion_diary,
            "active_diary": active_diary,
            "user_id": user_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))