from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from db.chroma import chroma_db
from core.chatbot import chatbot
import logging

router = APIRouter()


class MessageRequest(BaseModel):
    user_id: int
    message: str
    is_voice: bool = False


class MessageResponse(BaseModel):
    message: str
    created_at: datetime
    success: bool


@router.post("/chat/message", response_model=MessageResponse)
async def send_message(request: MessageRequest):
    """
    사용자가 메시지를 보내는 API
    텍스트와 음성 메시지를 모두 처리하며, 사용자 프로필과 컨텍스트를 활용하여
    개인화된 응답을 생성합니다.
    """
    try:
        now = datetime.now()
        logging.info(f"사용자 {request.user_id}로부터 메시지 수신: {request.message[:20]}...")

        response_message = ""

        # 음성 메시지 처리
        if request.is_voice:
            voice_result = chatbot.generate_voice_response(request.message, request.user_id)

            if voice_result["success"]:
                # 음성에서 텍스트로 변환된 메시지로 chatbot.get_response 호출
                transcribed_text = voice_result["transcribed_text"]
                logging.info(f"음성을 텍스트로 변환: {transcribed_text[:20]}...")

                # 비동기 방식으로 개인화된 응답 생성
                response_message = await chatbot.get_response(
                    request.user_id,
                    transcribed_text
                )
            else:
                # 음성 인식 실패 시 기본 오류 메시지 반환
                response_message = voice_result["response"]
        else:
            # 텍스트 메시지 - 비동기 방식으로 개인화된 응답 생성
            response_message = await chatbot.get_response(
                request.user_id,
                request.message
            )

        # 응답 반환 (대화 내용 저장은 chatbot.get_response 내에서 처리됨)
        return MessageResponse(
            message=response_message,
            created_at=datetime.now(),
            success=True
        )

    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        logging.error(f"Error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류")


class ChatHistoryRequest(BaseModel):
    user_id: int
    limit: Optional[int] = 50


@router.post("/chat/history", response_model=List[dict])
async def get_chat_history(request: ChatHistoryRequest):
    """사용자의 채팅 기록을 가져오는 API"""
    try:
        # 사용자의 컬렉션 가져오기
        collection = chroma_db.get_or_create_collection(request.user_id)

        # 모든 메시지 가져오기
        results = collection.get(limit=request.limit * 2)  # 사용자와 AI 메시지를 모두 가져오기 위해 2배로 설정

        if not results or not results["documents"]:
            return []

        # 결과를 메시지 목록으로 변환
        messages = []
        for i, doc in enumerate(results["documents"]):
            metadata = results["metadatas"][i]
            message_id = results["ids"][i]

            # 타임스탬프 정보가 없는 경우 현재 시간 사용
            created_at = datetime.now().isoformat()

            messages.append({
                "message_id": message_id,
                "message": doc,
                "is_user": metadata["type"] == "user",
                "is_voice": False,  # 현재 구현에서는 음성 메시지 구분 없음
                "created_at": created_at
            })

        # 메시지 순서 정렬 (현재 구현에서는 시간 정보가 없어 ID 순서로 정렬)
        messages.sort(key=lambda x: x["message_id"])

        return messages

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))