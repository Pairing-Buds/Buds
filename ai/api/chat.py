from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from db.chroma import chroma_db
from db.mysql import mysql_db
from core.chatbot import chatbot
import logging

from core.jwt_auth import get_user_id_from_token
router = APIRouter()

class MessageRequest(BaseModel):
    message: str
    is_voice: bool = False

class MessageResponse(BaseModel):
    message: str
    created_at: datetime


class ChatHistoryRequest(BaseModel):
    limit: Optional[int] = 50


@router.post("/chat/message", response_model=MessageResponse)
async def send_message(
        request: MessageRequest,
        user_id: int = Depends(get_user_id_from_token)
):
    """
    사용자가 메시지를 보내는 API
    텍스트와 음성 메시지를 모두 처리하며, 사용자 프로필과 컨텍스트를 활용하여
    개인화된 응답을 생성합니다.
    """
    logging.info(f"사용자 식별자 : {user_id}")
    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        now = datetime.now()
        logging.info(f"사용자 {user_id}로부터 메시지 수신: {request.message[:20]}...")

        response_message = ""

        # 음성 메시지 처리
        if request.is_voice:
            voice_result = chatbot.generate_voice_response(request.message, user_id)

            if voice_result["success"]:
                # 음성에서 텍스트로 변환된 메시지로 chatbot.get_response 호출
                transcribed_text = voice_result["transcribed_text"]
                logging.info(f"음성을 텍스트로 변환: {transcribed_text[:20]}...")

                # 비동기 방식으로 개인화된 응답 생성
                response_message = await chatbot.get_response(
                    user_id,
                    transcribed_text
                )

                # 음성 메시지임을 표시하여 저장
                chroma_db.save_conversation(user_id, transcribed_text, response_message, is_voice=True)
            else:
                # 음성 인식 실패 시 기본 오류 메시지 반환
                response_message = voice_result["response"]
        else:
            # 텍스트 메시지 - 비동기 방식으로 개인화된 응답 생성
            response_message = await chatbot.get_response(
                user_id,
                request.message
            )

            # 텍스트 메시지 저장
            chroma_db.save_conversation(user_id, request.message, response_message, is_voice=False)

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
async def get_chat_history(
        request: ChatHistoryRequest,
        user_id: int = Depends(get_user_id_from_token)
):
    logging.info(f"사용자 식별자 : {user_id}")
    """사용자의 채팅 기록을 가져오는 API"""
    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        # 사용자의 컬렉션 가져오기
        collection = chroma_db.get_or_create_collection(user_id)

        # 모든 메시지 가져오기
        results = collection.get(limit=request.limit * 2)  # 사용자와 AI 메시지를 모두 가져오기 위해 2배로 설정

        if not results or not results["documents"]:
            return []

        # 결과를 메시지 목록으로 변환
        messages = []
        for i, doc in enumerate(results["documents"]):
            metadata = results["metadatas"][i]
            message_id = results["ids"][i]

            # 타임스탬프 정보 가져오기
            created_at = metadata.get("timestamp", datetime.now().isoformat())

            # 음성 메시지 여부 확인
            is_voice = metadata.get("is_voice", False)

            messages.append({
                "message_id": message_id,
                "message": doc,
                "is_user": metadata["type"] == "user",
                "is_voice": is_voice,  # 음성 메시지 여부 추가
                "created_at": created_at
            })

        # 메시지 순서 정렬 (ID 기반 정렬)
        messages.sort(key=lambda x: x["message_id"])

        return messages

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"채팅 기록 조회 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")