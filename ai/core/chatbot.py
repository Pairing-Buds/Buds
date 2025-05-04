from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
import logging
import os
import tempfile
import openai
from db.mysql import mysql_db
from db.chroma import chroma_db
from core.prompts import generate_system_prompt
from pydantic_settings import BaseSettings
import base64


class Chatbot:
    def __init__(self):
        # 환경 변수에서 직접 API 키를 가져옴
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")

        self.chat = ChatOpenAI(
            model="gpt-4o",
            temperature=0.1,
            openai_api_key=api_key
        )

        # OpenAI 직접 API 키 설정
        openai.api_key = api_key

        logging.info("Chatbot 인스턴스가 초기화되었습니다.")

    async def get_response(self, user_id, message, message_count=0):
        """사용자 메시지에 대한 응답을 생성합니다."""
        try:
            # 1. 사용자 프로필 가져오기
            user_profile = mysql_db.get_user_profile(user_id)
            if not user_profile:
                raise ValueError(f"사용자 ID {user_id}에 대한 프로필을 찾을 수 없습니다.")

            # 2. 유사한 대화 컨텍스트 검색
            context = chroma_db.get_similar_conversations(user_id, message)

            # 3. 시스템 프롬프트 생성
            system_prompt = generate_system_prompt(user_profile, context)

            # 활동 추천 시점 확인
            if message_count > 0 and message_count % 6 == 0:
                system_prompt += "\n[중요] 활동을 추천해주세요!"

            # 4. LLM을 사용하여 응답 생성
            response = await self.chat.ainvoke([
                SystemMessage(content=system_prompt),
                HumanMessage(content=f"Context: {context}\nUser: {message}")
            ])

            # 5. 대화 내용 저장
            chroma_db.save_conversation(user_id, message, response.content)

            return response.content

        except Exception as e:
            logging.error(f"챗봇 응답 생성 중 오류: {str(e)}")
            raise

    def generate_response(self, message, user_id=None):
        """
        사용자 메시지에 대한 동기식 응답 생성 (chat_routes에서 사용)

        OpenAI API를 사용하여 응답을 생성합니다.
        """
        try:
            # OpenAI API 직접 호출로 응답 생성
            response = openai.ChatCompletion.create(
                model="gpt-4o",
                messages=[
                    {"role": "system", "content": "당신은 사용자와 대화하는 친절하고 공감적인 챗봇입니다."},
                    {"role": "user", "content": message}
                ],
                temperature=0.1
            )

            # 응답 추출
            result = response.choices[0].message.content.strip()

            # 대화 내용 저장 (user_id가 제공된 경우)
            if user_id:
                chroma_db.save_conversation(user_id, message, result)

            return result

        except Exception as e:
            # 오류 발생 시 기본 응답
            logging.error(f"응답 생성 오류: {str(e)}")

            # 최신 OpenAI API 형식 시도
            try:
                response = openai.chat.completions.create(
                    model="gpt-4o",
                    messages=[
                        {"role": "system", "content": "당신은 사용자와 대화하는 친절하고 공감적인 챗봇입니다."},
                        {"role": "user", "content": message}
                    ],
                    temperature=0.1
                )

                # 응답 추출
                result = response.choices[0].message.content.strip()

                # 대화 내용 저장 (user_id가 제공된 경우)
                if user_id:
                    chroma_db.save_conversation(user_id, message, result)

                return result

            except:
                return "죄송합니다. 응답을 생성하는 동안 오류가 발생했습니다."

    def generate_emotion_diary(self, chat_history):
        """
        채팅 기록을 바탕으로 감정을 어루만지는 감정 일기 생성
        """
        prompt = f"""
        다음은 사용자와의 오늘 채팅 기록입니다:

        {chat_history}

        이 채팅 기록을 바탕으로 사용자의 감정을 이해하고 어루만져줄 수 있는 사용자 입장에서의 감정 일기를 작성해주세요.
        감정적인 표현을 활용하고, 사용자의 기분과 심리상태를 공감하는 내용이어야 합니다.
        1인칭 시점으로 작성하며, 200자 이내로 요약해주세요.
        """

        response = self.generate_response(prompt)
        return response

    def generate_active_diary(self, chat_history):
        """
        채팅 기록을 바탕으로 객관적인 행동 일기 생성
        """
        prompt = f"""
        다음은 사용자와의 오늘 채팅 기록입니다:

        {chat_history}

        이 채팅 기록을 바탕으로 사용자의 행동과 활동을 객관적으로 분석하는 행동 일기를 작성해주세요.
        사실적이고 객관적인 표현을 사용하고, 사용자의 행동과 결정에 대해 분석하는 내용이어야 합니다.
        1인칭 시점으로 작성하며, 200자 이내로 요약해주세요.
        """

        response = self.generate_response(prompt)
        return response

    def generate_voice_response(self, voice_message, user_id):
        """
        음성 메시지를 처리하고 응답 생성

        Base64로 인코딩된 오디오 데이터를 받아 텍스트로 변환한 후 처리합니다.
        OpenAI Whisper API를 사용하여 음성을 텍스트로 변환합니다.
        """
        try:
            # 1. Base64 디코딩 (클라이언트에서 Base64로 인코딩된 오디오 데이터 전송 가정)
            audio_data = base64.b64decode(voice_message)

            # 2. 임시 파일로 저장
            with tempfile.NamedTemporaryFile(delete=False, suffix='.mp3') as temp_audio_file:
                temp_audio_file.write(audio_data)
                temp_audio_path = temp_audio_file.name

            # 3. OpenAI Whisper API를 사용하여 음성을 텍스트로 변환
            try:
                with open(temp_audio_path, 'rb') as audio_file:
                    transcript = openai.Audio.transcribe(
                        file=audio_file,
                        model="whisper-1",
                        language="ko"  # 한국어 지정 (다른 언어도 가능)
                    )

                # 4. 텍스트 추출
                transcribed_text = transcript["text"]

                # 5. 임시 파일 삭제
                os.unlink(temp_audio_path)

                # 6. 텍스트로 변환된 음성 메시지로 응답 생성
                response = self.generate_response(transcribed_text, user_id)

                return {
                    "success": True,
                    "transcribed_text": transcribed_text,
                    "response": response
                }

            except Exception as e:
                # 음성 인식 실패 시 오류 처리
                return {
                    "success": False,
                    "error": f"음성 인식 실패: {str(e)}",
                    "response": "죄송합니다. 음성을 인식하는 데 문제가 있었습니다. 텍스트로 메시지를 보내주시겠어요?"
                }

        finally:
            # 임시 파일이 남아있는 경우 삭제
            if 'temp_audio_path' in locals() and os.path.exists(temp_audio_path):
                try:
                    os.unlink(temp_audio_path)
                except:
                    pass


# 전역 Chatbot 인스턴스
chatbot = Chatbot()