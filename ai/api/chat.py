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
    remaining_messages: int  # 남은 메시지 수 추가
    audio_path: Optional[str] = None  # TTS 오디오 파일 경로 추가


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

    is_voice가 True인 경우, TTS 응답도 함께 생성합니다.
    """

    try:
        # 사용자 인증 확인
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            raise HTTPException(status_code=401, detail=f"인증 오류: {str(e)}")

        now = datetime.now()
        logging.info(f"사용자 {user_id}로부터 메시지 수신: {request.message[:20]}...")
        logging.info(f"음성 입력: {request.is_voice}")

        # 메시지 카운트 가져오기 - 필요한 경우 데이터베이스에서 오늘의 메시지 수 조회
        today = now.strftime('%Y-%m-%d')
        message_count = chroma_db.get_daily_message_count(user_id, today)

        # 일일 제한 확인
        if message_count >= 100:
            raise HTTPException(
                status_code=429,
                detail="오늘의 메시지 한도(100)에 도달했습니다. 내일 다시 대화해주세요."
            )

        # 텍스트 메시지 처리 - 비동기 방식으로 개인화된 응답 생성
        # is_voice 파라미터를 전달하여 음성 응답도 함께 생성
        response = await chatbot.get_response(
            user_id,
            request.message,
            message_count=message_count,
            is_voice=request.is_voice  # 음성 입력이 들어왔을 때 음성 출력도 생성
        )

        # 응답 형식 확인 및 처리
        if isinstance(response, dict) and "text" in response and "audio_path" in response:
            # TTS 응답이 포함된 경우
            text_response = response["text"]
            audio_path = response["audio_path"]

            # 오디오 파일 URL 생성
            audio_url = None
            if audio_path:
                audio_filename = os.path.basename(audio_path)
                audio_url = f"/api/audio/{audio_filename}"
        else:
            # 일반 텍스트 응답만 있는 경우
            text_response = response
            audio_url = None

        # 메시지 저장 (음성 원본 여부 표시)
        chroma_db.save_conversation(
            user_id,
            request.message,
            text_response,
            is_voice=request.is_voice
        )

        # 남은 메시지 수 계산
        remaining_messages = 100 - (message_count + 1)

        # 응답 반환
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
                "is_voice": is_voice,  # 메시지가 원래 음성이었는지 여부
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
                f"메시지 {i + 1}: ID={msg['message_id']}, 생성시간={msg['created_at']}, 사용자={msg['is_user']}, 음성원본={msg['is_voice']}")

        return messages

    except HTTPException:
        raise
    except Exception as e:
        logging.error(f"채팅 기록 조회 오류: {str(e)}")
        raise HTTPException(status_code=500, detail=f"서버 오류: {str(e)}")