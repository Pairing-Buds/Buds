from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from db.chroma import chroma_db
from db.mysql import mysql_db
from core.chatbot import chatbot
import logging

router = APIRouter()


class MessageRequest(BaseModel):
    user_id: int
    message: str
    is_voice_recognition: bool = False  # 클라이언트에서 음성인식한 경우 true
    original_message: Optional[str] = None  # 원본 음성텍스트 (있는 경우)


class MessageResponse(BaseModel):
    message: str
    created_at: datetime
    success: bool


class ChatHistoryRequest(BaseModel):
    user_id: int
    limit: Optional[int] = 50


@router.post("/chat/message", response_model=MessageResponse)
async def send_message(request: MessageRequest):
    """
    사용자가 메시지를 보내는 API
    텍스트와 음성 메시지를 모두 처리하며, 사용자 프로필과 컨텍스트를 활용하여
    개인화된 응답을 생성합니다.
    """
    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(request.user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        now = datetime.now()
        logging.info(f"사용자 {request.user_id}로부터 메시지 수신: {request.message[:20]}...")

        # 음성 인식된 메시지 처리
        if request.is_voice_recognition:
            logging.info(f"클라이언트에서 음성 인식된 메시지: {request.message[:20]}...")

            # 원본 음성 메시지가 제공된 경우 (선택 사항)
            original_message = request.original_message if request.original_message else request.message

            # 비동기 방식으로 개인화된 응답 생성
            response_message = await chatbot.get_response(
                request.user_id,
                request.message
            )

            # 음성 인식 메시지임을 표시하여 저장
            chroma_db.save_conversation(
                request.user_id,
                request.message,
                response_message,
                is_voice=True,
                original_voice_text=original_message
            )
        else:
            # 일반 텍스트 메시지 - 비동기 방식으로 개인화된 응답 생성
            response_message = await chatbot.get_response(
                request.user_id,
                request.message
            )

            # 텍스트 메시지 저장
            chroma_db.save_conversation(request.user_id, request.message, response_message, is_voice=False)

        # 응답 반환
        return MessageResponse(
            message=response_message,
            created_at=datetime.now(),
            success=True
        )

    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류")


@router.post("/chat/history", response_model=List[dict])
async def get_chat_history(request: ChatHistoryRequest):
    """사용자의 채팅 기록을 가져오는 API"""
    # (이전 코드와 동일하게 유지)