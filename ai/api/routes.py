from fastapi import APIRouter, HTTPException
import logging
from models.conversation import MessageRequest, MessageResponse
from core.chatbot import chatbot

router = APIRouter()


@router.post("/api/ask", response_model=MessageResponse)
async def ask(message_request: MessageRequest):
    """HTTP POST 방식으로 챗봇에게 메시지를 보내는 엔드포인트"""
    try:
        logging.info(f"사용자 {message_request.user_id}로부터 메시지 수신: {message_request.message[:20]}...")

        # 챗봇 응답 생성
        response = await chatbot.get_response(
            message_request.user_id,
            message_request.message
        )

        return {"reply": response}

    except ValueError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        logging.error(f"Error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류")