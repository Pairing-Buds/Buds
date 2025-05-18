from fastapi import APIRouter, HTTPException, Depends, Response, File, UploadFile, BackgroundTasks
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
from datetime import datetime
from db.chroma import chroma_db
from db.mysql import mysql_db
from core.chatbot import chatbot
import logging
import os
import tempfile

from core.jwt_auth import get_user_id_from_token

router = APIRouter()


class MessageRequest(BaseModel):
    message: str
    is_voice: bool = False


class MessageResponse(BaseModel):
    message: str
    created_at: datetime
    remaining_messages: int
    audio_path: Optional[str] = None


class ChatHistoryRequest(BaseModel):
    limit: Optional[int] = 20
    offset: Optional[int] = 0  # 건너뛸 메시지 수


@router.post("/chat/message", response_model=MessageResponse)
async def send_message(
        request: MessageRequest,
        background_tasks: BackgroundTasks,
        user_id: int = Depends(get_user_id_from_token)
):
    """
    사용자가 메시지를 보내는 API
    텍스트 메시지를 처리하며, 사용자 프로필과 컨텍스트를 활용하여
    개인화된 응답을 생성합니다.

    is_voice가 True인 경우, TTS 응답도 함께 생성합니다.
    """

    try:
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        now = datetime.now()
        logging.info(f"사용자 {user_id}로부터 메시지 수신: {request.message[:20]}...")
        logging.info(f"음성 입력: {request.is_voice}")

        message_count = 0
        try:
            today = now.strftime('%Y-%m-%d')
            message_count = chroma_db.get_daily_message_count(user_id, today)
        except ConnectionError as e:
            logging.error(f"ChromaDB 연결 오류 (메시지 카운트): {str(e)}")
        except Exception as e:
            logging.error(f"메시지 카운트 조회 오류: {str(e)}")

        if message_count >= 100:
            raise HTTPException(
                status_code=429,
                detail="오늘의 메시지 한도(100)에 도달했습니다. 내일 다시 대화해주세요."
            )

        # 🧠 GPT 응답 받기
        try:
            response = await chatbot.get_response(
                user_id,
                request.message,
                message_count=message_count,
                is_voice=request.is_voice
            )
        except ConnectionError as e:
            logging.error(f"ChromaDB 연결 오류 (응답 생성): {str(e)}")
            simple_response = "죄송합니다. 현재 대화 기록 시스템에 연결할 수 없습니다. 기본 응답만 제공해 드립니다."
            response = {"text": simple_response} if request.is_voice else simple_response

        # ✅ 텍스트 응답 추출
        if isinstance(response, dict) and "text" in response:
            text_response = response["text"]
        else:
            text_response = response

        # ✅ TTS 비동기 생성 예약
        audio_url = None
        if request.is_voice:
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            audio_filename = f"animalese_{user_id}_{timestamp}.wav"
            audio_path = os.path.join(tempfile.gettempdir(), audio_filename)

            # generate_animalese_tts 함수에 정확한 파일명 전달
            background_tasks.add_task(
                chatbot.generate_animalese_tts,
                text_response,
                user_id,
                audio_filename
            )

            # 프론트에서 접근할 수 있도록 URL 반환
            audio_url = f"/api/audio/{audio_filename}"

        # 대화 저장
        try:
            chroma_db.save_conversation(
                user_id,
                request.message,
                text_response,
                is_voice=request.is_voice
            )
        except ConnectionError as e:
            logging.error(f"ChromaDB 연결 오류 (대화 저장): {str(e)}")
        except Exception as e:
            logging.error(f"대화 저장 오류: {str(e)}")

        remaining_messages = 100 - (message_count + 1)

        return MessageResponse(
            message=text_response,
            created_at=datetime.now(),
            remaining_messages=remaining_messages,
            audio_path=audio_url
        )

    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"Error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류")



@router.post("/chat/history", response_model=Dict[str, Any])
async def get_chat_history(
        request: ChatHistoryRequest,
        user_id: int = Depends(get_user_id_from_token)
):
    """
    사용자의 채팅 기록을 가져오는 API (오프셋 기반 무한 스크롤)
    """
    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        # 메시지와 전체 개수 가져오기
        try:
            messages, total_count = chroma_db.get_conversation_history_with_offset(
                user_id=user_id,
                limit=request.limit,
                offset=request.offset
            )
        except ConnectionError as e:
            logging.error(f"ChromaDB 연결 오류 (대화 기록 조회): {str(e)}")
            # 연결 오류 시 빈 결과 반환
            return {
                "messages": [],
                "has_more": False,
                "next_offset": None,
                "total_count": 0,
                "error": "대화 기록을 불러올 수 없습니다. 서버 연결 오류가 발생했습니다."
            }
        except Exception as e:
            logging.error(f"대화 기록 조회 오류: {str(e)}")
            # 다른 오류도 비슷하게 처리하지만, 오류 메시지만 다르게
            return {
                "messages": [],
                "has_more": False,
                "next_offset": None,
                "total_count": 0,
                "error": f"대화 기록을 불러올 수 없습니다: {str(e)}"
            }

        # 다음 오프셋 계산
        next_offset = request.offset + len(messages)
        has_more = next_offset < total_count

        return {
            "messages": messages,
            "has_more": has_more,
            "next_offset": next_offset if has_more else None,
            "total_count": total_count
        }

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"채팅 기록 조회 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")


@router.get("/test/chroma_connection")
async def test_chroma_connection():
    """ChromaDB 연결 테스트 엔드포인트"""
    try:
        # 연결 상태 확인
        collections = chroma_db.client.list_collections()

        return {
            "status": "success",
            "message": "ChromaDB 연결 성공",
            "collections_count": len(collections),
            "collections": [c.name for c in collections[:10]],  # 최대 10개만 표시
            "client_info": {
                "type": str(type(chroma_db.client)),
                "host": getattr(chroma_db.client, '_host', 'unknown'),
                "port": getattr(chroma_db.client, '_port', 'unknown')
            }
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"ChromaDB 연결 오류: {str(e)}"
        }


@router.get("/api/audio/{filename}")
async def get_audio_file(filename: str, background_tasks: BackgroundTasks):
    try:
        audio_path = os.path.join(tempfile.gettempdir(), filename)

        if not os.path.exists(audio_path):
            raise HTTPException(status_code=404, detail="오디오 파일을 찾을 수 없습니다")

        # 백그라운드 작업으로 파일 삭제 예약
        background_tasks.add_task(remove_file, audio_path)

        return FileResponse(path=audio_path, media_type="audio/wav", filename=filename)
    except Exception as e:
        logging.error(f"오디오 파일 제공 중 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"오디오 파일 처리 중 오류: {str(e)}")


# 파일 삭제 함수 정의
def remove_file(file_path: str):
    """음성 파일 응답 후 파일 삭제"""
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            logging.info(f"음성 파일이 성공적으로 삭제되었습니다: {file_path}")
        else:
            logging.warning(f"삭제할 파일이 존재하지 않습니다: {file_path}")
    except Exception as e:
        logging.error(f"파일 삭제 중 오류 발생: {file_path}, 오류: {str(e)}")