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
    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(request.user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

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

            # 타임스탬프 정보 가져오기 (ISO 형식: '2025-05-08T12:59:31.195')
            created_at = metadata.get("timestamp", datetime.now().isoformat())

            # 음성 메시지 여부 확인
            is_voice = metadata.get("is_voice", False)

            # 원본 음성 텍스트 (있는 경우)
            original_voice_text = metadata.get("original_voice_text", None)

            message_data = {
                "message_id": message_id,
                "message": doc,
                "is_user": metadata["type"] == "user",
                "is_voice": is_voice,
                "created_at": created_at
            }

            # 원본 음성 텍스트가 있는 경우 추가
            if original_voice_text:
                message_data["original_voice_text"] = original_voice_text

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
            logging.info(f"메시지 {i + 1}: ID={msg['message_id']}, 생성시간={msg['created_at']}, 사용자={msg['is_user']}")

        return messages

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"채팅 기록 조회 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")