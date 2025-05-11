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
    is_voice_origin: bool = False  # 메시지가 원래 음성에서 STT로 변환되었는지 여부


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
    텍스트 메시지를 처리하며, 사용자 프로필과 컨텍스트를 활용하여
    개인화된 응답을 생성합니다.

    Flutter에서 STT로 처리된 음성 메시지도 텍스트로 받아 처리하고,
    원본이 음성인지 여부를 메타데이터로 기록합니다.
    """

    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        now = datetime.now()
        logging.info(f"사용자 {user_id}로부터 메시지 수신: {request.message[:20]}...")
        logging.info(f"음성 기원 메시지: {request.is_voice_origin}")

        # 텍스트 메시지 처리 - 비동기 방식으로 개인화된 응답 생성
        response_message = await chatbot.get_response(
            user_id,
            request.message
        )

        # 메시지 저장 (음성 원본 여부 표시)
        chroma_db.save_conversation(
            user_id,
            request.message,
            response_message,
            is_voice=request.is_voice_origin
        )

        # 응답 반환
        return MessageResponse(
            message=response_message,
            created_at=datetime.now()
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

            # 타임스탬프 정보 가져오기 (ISO 형식: '2025-05-08T12:59:31.195')
            created_at = metadata.get("timestamp", datetime.now().isoformat())

            # 음성 메시지 여부 확인
            is_voice = metadata.get("is_voice", False)

            message_data = {
                "message_id": message_id,
                "message": doc,
                "is_user": metadata["type"] == "user",
                "is_voice_origin": is_voice,  # 메시지가 원래 음성이었는지 여부
                "created_at": created_at
            }

            messages.append(message_data)

        # 메시지 순서를 타임스탬프 기준으로 정렬
        # ISO 형식의 타임스탬프를 datetime 객체로 변환하여 정렬
        try:
            messages.sort(key=lambda x: datetime.fromisoformat(x["created_at"]))
        except (ValueError, TypeError):
            # ISO 형식 파싱에 실패할 경우 message_id 기반 정렬 시도
            # message_id가 숫자 형식인 경우를 처리
            try:
                messages.sort(key=lambda x: int(x["message_id"]) if x["message_id"].isdigit() else x["message_id"])
            except (ValueError, TypeError):
                # 그래도 실패하면 문자열로 처리
                messages.sort(key=lambda x: str(x["message_id"]))

        # 대화 순서 로깅 (디버깅용)
        logging.info(f"정렬된 채팅 기록: {len(messages)}개 메시지")
        for i, msg in enumerate(messages[:5]):  # 처음 5개 메시지만 로깅
            logging.info(
                f"메시지 {i + 1}: ID={msg['message_id']}, 생성시간={msg['created_at']}, 사용자={msg['is_user']}, 음성원본={msg['is_voice_origin']}")

        return messages

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"채팅 기록 조회 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")