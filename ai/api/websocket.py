from fastapi import WebSocket, WebSocketDisconnect
import asyncio
import logging
import json
from core.chatbot import chatbot

class ConnectionManager:
    def __init__(self):
        self.active_connections = {}
        self.lock = asyncio.Lock()

    async def connect(self, user_id: str, websocket: WebSocket):
        async with self.lock:
            self.active_connections[user_id] = websocket

    async def disconnect(self, user_id: str):
        async with self.lock:
            self.active_connections.pop(user_id, None)

connection_manager = ConnectionManager()

async def websocket_endpoint(websocket: WebSocket, user_id: int):
    """WebSocket을 통한 실시간 채팅 처리"""
    await websocket.accept()
    await connection_manager.connect(str(user_id), websocket)
    logging.info(f"사용자 {user_id}의 WebSocket 연결이 수락되었습니다.")

    # 챗봇이 먼저 인사말을 보냄
    greeting = await chatbot.get_response(user_id, "친구에게 먼저 인사해줘")
    await websocket.send_json({
        "from": "ai",
        "message": greeting
    })

    # 연결 상태 모니터링 태스크
    async def heartbeat():
        while True:
            await asyncio.sleep(30)
            try:
                await websocket.send_json({"type": "heartbeat"})
            except:
                break

    heartbeat_task = asyncio.create_task(heartbeat())

    try:
        msg_counter = 0
        while True:
            data = await websocket.receive_json()
            user_message = data.get("content")

            # 메시지 유효성 검사
            if not user_message:
                await websocket.send_json({"error": "메시지 필수"})
                continue

            msg_counter += 1

            # 챗봇 응답 생성
            response = await chatbot.get_response(
                user_id,
                user_message,
                message_count=msg_counter
            )

            # 응답 전송
            await websocket.send_json({
                "from": "ai",
                "message": response
            })

    except WebSocketDisconnect:
        logging.info(f"사용자 {user_id}의 연결이 종료되었습니다.")
    except Exception as e:
        logging.error(f"WebSocket 처리 중 오류: {str(e)}")
        await websocket.send_json({"error": "내부 서버 오류"})
    finally:
        await connection_manager.disconnect(str(user_id))
        await websocket.close()