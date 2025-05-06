from fastapi import WebSocket, WebSocketDisconnect
import asyncio
import logging
import json
import base64
import os
import tempfile
from datetime import datetime
from core.chatbot import chatbot
from db.chroma import chroma_db
from db.mysql import mysql_db


class ConnectionManager:
    def __init__(self):
        self.active_connections = {}
        self.lock = asyncio.Lock()
        # 음성 스트림 버퍼 저장 (사용자 ID별)
        self.voice_buffers = {}
        # 음성 인식 상태 추적
        self.voice_states = {}
        # 메시지 카운터
        self.message_counters = {}

    async def connect(self, user_id: str, websocket: WebSocket):
        async with self.lock:
            self.active_connections[user_id] = websocket
            # 음성 버퍼 초기화
            self.voice_buffers[user_id] = bytearray()
            # 음성 인식 상태 초기화
            self.voice_states[user_id] = {
                "is_processing": False,
                "last_voice_detected": datetime.now(),
                "voice_timeout": 1.5  # 음성 비활성화 타임아웃 (초)
            }
            # 메시지 카운터 초기화 (없는 경우)
            if user_id not in self.message_counters:
                self.message_counters[user_id] = 0

    async def disconnect(self, user_id: str):
        async with self.lock:
            self.active_connections.pop(user_id, None)
            self.voice_buffers.pop(user_id, None)
            self.voice_states.pop(user_id, None)

    def get_voice_buffer(self, user_id: str):
        return self.voice_buffers.get(user_id, bytearray())

    def update_voice_buffer(self, user_id: str, data):
        if user_id in self.voice_buffers:
            self.voice_buffers[user_id].extend(data)

    def clear_voice_buffer(self, user_id: str):
        if user_id in self.voice_buffers:
            self.voice_buffers[user_id] = bytearray()

    def get_voice_state(self, user_id: str):
        return self.voice_states.get(user_id, {})

    def update_voice_state(self, user_id: str, key, value):
        if user_id in self.voice_states:
            self.voice_states[user_id][key] = value

    def increment_message_counter(self, user_id: str):
        if user_id in self.message_counters:
            self.message_counters[user_id] += 1
            return self.message_counters[user_id]
        return 0

    def get_message_counter(self, user_id: str):
        return self.message_counters.get(user_id, 0)


connection_manager = ConnectionManager()


async def websocket_endpoint(websocket: WebSocket, user_id: int):
    """WebSocket을 통한 실시간 채팅 처리"""
    try:
        await websocket.accept()

        # 사용자 존재 여부 확인 (로그인 여부 확인)
        try:
            mysql_db.get_user_profile(user_id)
        except ValueError as e:
            # 사용자가 없거나 로그인되지 않은 경우
            await websocket.send_json({
                "error": f"인증 오류: {str(e)}. 다시 로그인해주세요."
            })
            await websocket.close()
            return

        await connection_manager.connect(str(user_id), websocket)
        logging.info(f"사용자 {user_id}의 WebSocket 연결이 수락되었습니다.")

        # 챗봇이 먼저 인사말을 보냄
        try:
            greeting = await chatbot.get_response(user_id, "친구에게 먼저 인사해줘")
            await websocket.send_json({
                "from": "ai",
                "message": greeting
            })
        except ValueError as e:
            logging.error(f"인사말 생성 오류: {str(e)}")
            await websocket.send_json({
                "error": "인사말을 생성하는 중 오류가 발생했습니다."
            })

        # 연결 상태 모니터링 태스크
        async def heartbeat():
            while True:
                await asyncio.sleep(30)
                try:
                    await websocket.send_json({"type": "heartbeat"})
                except:
                    break

        # 음성 처리 모니터링 태스크
        async def voice_monitor():
            user_id_str = str(user_id)
            while True:
                await asyncio.sleep(0.1)  # 100ms 간격으로 확인

                voice_state = connection_manager.get_voice_state(user_id_str)
                if not voice_state:
                    continue

                current_time = datetime.now()
                last_voice_time = voice_state.get("last_voice_detected", current_time)
                is_processing = voice_state.get("is_processing", False)
                timeout = voice_state.get("voice_timeout", 1.5)

                # 음성 비활성 시간이 타임아웃을 초과하고 처리 중이 아닐 때
                time_diff = (current_time - last_voice_time).total_seconds()
                if time_diff > timeout and not is_processing:
                    buffer = connection_manager.get_voice_buffer(user_id_str)

                    # 버퍼에 데이터가 있으면 처리
                    if len(buffer) > 0:
                        connection_manager.update_voice_state(user_id_str, "is_processing", True)
                        # 비동기로 오디오 처리 시작
                        asyncio.create_task(process_audio(websocket, buffer, user_id))
                        # 처리 후 버퍼 초기화
                        connection_manager.clear_voice_buffer(user_id_str)

        heartbeat_task = asyncio.create_task(heartbeat())
        voice_monitor_task = asyncio.create_task(voice_monitor())

        try:
            while True:
                data = await websocket.receive_json()

                # 메시지 유형 확인
                message_type = data.get("type", "text")

                if message_type == "text":
                    # 일반 텍스트 메시지 처리
                    user_message = data.get("content")

                    # 메시지 유효성 검사
                    if not user_message:
                        await websocket.send_json({"error": "메시지가 비어있습니다"})
                        continue

                    try:
                        # 메시지 카운터 증가
                        msg_counter = connection_manager.increment_message_counter(str(user_id))

                        # 챗봇 응답 생성
                        response = await chatbot.get_response(
                            user_id,
                            user_message,
                            message_count=msg_counter
                        )

                        # 대화 내용 저장
                        chroma_db.save_conversation(user_id, user_message, response, is_voice=False)

                        # 응답 전송
                        await websocket.send_json({
                            "from": "ai",
                            "message": response
                        })
                    except ValueError as e:
                        await websocket.send_json({
                            "error": f"응답 생성 오류: {str(e)}"
                        })

                elif message_type == "voice":
                    # 음성 메시지 처리
                    voice_data = data.get("voice_data")
                    voice_command = data.get("command", "")

                    user_id_str = str(user_id)

                    if voice_command == "start":
                        # 음성 세션 시작
                        connection_manager.clear_voice_buffer(user_id_str)
                        connection_manager.update_voice_state(user_id_str, "is_processing", False)
                        await websocket.send_json({
                            "type": "voice_status",
                            "status": "ready",
                            "message": "음성 인식 시작"
                        })

                    elif voice_command == "end":
                        # 음성 세션 종료 및 남은 버퍼 처리
                        buffer = connection_manager.get_voice_buffer(user_id_str)
                        if len(buffer) > 0:
                            await process_audio(websocket, buffer, user_id)

                        await websocket.send_json({
                            "type": "voice_status",
                            "status": "completed",
                            "message": "음성 인식 세션 종료"
                        })

                    else:
                        # 음성 데이터 처리
                        if voice_data:
                            try:
                                # Base64로 인코딩된 오디오 데이터를 디코딩
                                audio_chunk = base64.b64decode(voice_data)

                                # 버퍼에 추가
                                connection_manager.update_voice_buffer(user_id_str, audio_chunk)

                                # VAD 데이터 확인
                                is_voice_active = data.get("is_voice_active", False)
                                if is_voice_active:
                                    connection_manager.update_voice_state(
                                        user_id_str,
                                        "last_voice_detected",
                                        datetime.now()
                                    )
                                    connection_manager.update_voice_state(
                                        user_id_str,
                                        "is_processing",
                                        False
                                    )
                            except Exception as e:
                                logging.error(f"음성 데이터 처리 오류: {str(e)}")
                                await websocket.send_json({
                                    "error": f"음성 데이터 처리 오류: {str(e)}"
                                })
                else:
                    # 알 수 없는 메시지 유형
                    await websocket.send_json({
                        "error": f"알 수 없는 메시지 유형: {message_type}"
                    })

        except WebSocketDisconnect:
            logging.info(f"사용자 {user_id}의 연결이 종료되었습니다.")
        except json.JSONDecodeError:
            logging.error(f"JSON 디코딩 오류: 잘못된 JSON 형식")
            await websocket.send_json({"error": "잘못된 메시지 형식"})
        except Exception as e:
            logging.error(f"WebSocket 처리 중 오류: {str(e)}", exc_info=True)
            await websocket.send_json({"error": f"내부 서버 오류: {str(e)}"})
        finally:
            heartbeat_task.cancel()
            voice_monitor_task.cancel()
            await connection_manager.disconnect(str(user_id))
            await websocket.close()
    except Exception as e:
        logging.error(f"WebSocket 초기화 오류: {str(e)}", exc_info=True)
        try:
            await websocket.close()
        except:
            pass


async def process_audio(websocket, audio_buffer, user_id):
    """
    오디오 청크를 처리하고 음성 인식 결과를 반환합니다.
    """
    try:
        # 오디오 버퍼를 Base64로 인코딩
        audio_data_b64 = base64.b64encode(audio_buffer).decode('utf-8')

        # 음성 인식 및 응답 생성 시작 알림
        await websocket.send_json({
            "type": "voice_status",
            "status": "processing",
            "message": "음성 인식 및 응답 생성 중..."
        })

        # 음성 인식 처리
        voice_result = await chatbot.process_continuous_voice(audio_data_b64, user_id)

        if voice_result["success"] and voice_result["transcribed_text"].strip():
            transcribed_text = voice_result["transcribed_text"]

            # 클라이언트에 인식된 텍스트 전송
            await websocket.send_json({
                "type": "voice_transcription",
                "text": transcribed_text
            })

            # 메시지 카운터 증가
            msg_counter = connection_manager.increment_message_counter(str(user_id))

            # 챗봇 응답
            response = voice_result["response"]

            # 대화 내용 저장 (음성 메시지로 표시)
            chroma_db.save_conversation(user_id, transcribed_text, response, is_voice=True)

            # 클라이언트에 응답 전송
            await websocket.send_json({
                "from": "ai",
                "message": response,
                "type": "voice_response"
            })

            # 처리 완료 후 상태 업데이트
            connection_manager.update_voice_state(str(user_id), "is_processing", False)
        else:
            # 음성 인식 실패 또는 빈 텍스트인 경우
            await websocket.send_json({
                "type": "voice_status",
                "status": "error",
                "message": voice_result.get("error", "음성을 인식할 수 없습니다.")
            })
            connection_manager.update_voice_state(str(user_id), "is_processing", False)

    except Exception as e:
        logging.error(f"오디오 처리 오류: {str(e)}", exc_info=True)
        await websocket.send_json({
            "type": "error",
            "message": f"음성 처리 중 오류 발생: {str(e)}"
        })
        # 오류 발생 시에도 처리 상태 업데이트
        connection_manager.update_voice_state(str(user_id), "is_processing", False)