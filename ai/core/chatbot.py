from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage, AIMessage
import logging
import os
import tempfile
import openai
from db.mysql import mysql_db
from db.chroma import chroma_db
from core.prompts import generate_system_prompt
import base64
import re
from datetime import datetime, timedelta


class Chatbot:
    def __init__(self):
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")

        self.chat = ChatOpenAI(
            model="gpt-4o",
            temperature=0.1
        )

        # OpenAI 직접 API 키 설정
        openai.api_key = api_key

        # 사용자별 일일 메시지 카운트 저장 딕셔너리
        self.daily_message_count = {}

        logging.info("Chatbot 인스턴스가 초기화되었습니다.")

    def _sanitize_input(self, text):
        """
        입력 텍스트를 정제하여 불필요한 공백과 특수문자를 처리합니다.
        """
        if not text or not isinstance(text, str):
            return ""

        # 앞뒤 공백 제거
        text = text.strip()

        # 연속된 공백을 하나로 치환
        text = re.sub(r'\s+', ' ', text)

        # 불필요한 특수문자 제거 (필요에 따라 조정)
        text = re.sub(r'[^\w\s가-힣ㄱ-ㅎㅏ-ㅣ.,!?;:()\-\'\"]+', '', text)

        return text

    def _check_daily_limit(self, user_id):
        """
        사용자의 일일 메시지 수를 확인하고 제한을 초과했는지 검사합니다.
        """
        today = datetime.now().strftime('%Y-%m-%d')
        user_key = f"{user_id}_{today}"

        # 오늘 첫 메시지인 경우 초기화
        if user_key not in self.daily_message_count:
            self.daily_message_count[user_key] = 0

            # 이전 날짜의 카운트는 정리 (메모리 관리)
            yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
            old_key = f"{user_id}_{yesterday}"
            if old_key in self.daily_message_count:
                del self.daily_message_count[old_key]

        # 현재 카운트 확인
        current_count = self.daily_message_count[user_key]

        # 제한 초과 확인
        if current_count >= 100:
            return False

        # 카운트 증가
        self.daily_message_count[user_key] += 1
        return True

    async def get_response(self, user_id, message, message_count=0):
        """사용자 메시지에 대한 응답을 생성합니다."""
        try:
            # 0. 메시지 정제
            sanitized_message = self._sanitize_input(message)
            if not sanitized_message:
                return "메시지가 비어있거나 유효하지 않습니다."

            # 0-1. 일일 메시지 제한 확인
            if not self._check_daily_limit(user_id):
                return "죄송합니다. 오늘의 대화 제한(100회)에 도달했습니다. 내일 다시 대화해주세요."

            # 1. 사용자 프로필 가져오기
            user_profile = mysql_db.get_user_profile(user_id)

            # 2. 최근 대화 기록 가져오기 (최적화된 방식)
            recent_history = chroma_db.get_recent_conversation_history(user_id, limit=15)

            # 3. 대화 요약본 가져오기 (이전 대화의 맥락)
            conversation_summary = chroma_db.get_conversation_summary(user_id)

            # 4. 유사한 대화 컨텍스트도 활용
            similar_context = chroma_db.get_similar_conversations(user_id, sanitized_message)

            # 5. 시스템 프롬프트 생성
            context_combined = f"""
            대화 요약:
            {conversation_summary if conversation_summary else "이전 대화 요약 없음"}

            최근 대화:
            {self._format_messages(recent_history) if recent_history else "최근 대화 없음"}

            관련 대화:
            {similar_context if similar_context else "관련 대화 없음"}
            """

            system_prompt = generate_system_prompt(user_profile, context_combined)

            # 활동 추천 시점 확인
            if message_count > 0 and message_count % 6 == 0:
                system_prompt += "\n[중요] 활동을 추천해주세요!"

            # 6. 대화 이력을 포함한 메시지 목록 구성
            messages = [SystemMessage(content=system_prompt)]

            # 최근 몇 개의 대화만 실제 메시지로 포함 (너무 많으면 토큰 제한에 걸림)
            for entry in recent_history[-6:]:  # 최근 3턴(6개 메시지)만 포함
                if entry["is_user"]:
                    messages.append(HumanMessage(content=entry["message"]))
                else:
                    messages.append(AIMessage(content=entry["message"]))

            # 현재 사용자 메시지 추가
            messages.append(HumanMessage(content=sanitized_message))

            # 7. LLM을 사용하여 응답 생성
            response = await self.chat.ainvoke(messages)

            # 8. 새로운 대화가 20개 이상 쌓였을 때 자동 요약 생성 및 저장
            message_total = chroma_db.get_message_count(user_id)
            if message_total % 20 == 0:  # 20개 메시지마다 요약 생성
                await self._update_conversation_summary(user_id)

            return response.content

        except ValueError as e:
            # 사용자 프로필 조회 실패 (로그인되지 않은 사용자 등)
            logging.error(f"사용자 정보 오류: {str(e)}")
            raise ValueError(f"사용자 인증 오류: {str(e)}")

        except Exception as e:
            logging.error(f"챗봇 응답 생성 중 오류: {str(e)}")
            raise ValueError(f"서비스 오류: {str(e)}")

    def _format_messages(self, messages):
        """메시지 리스트를 텍스트 포맷으로 변환합니다."""
        if not messages:
            return ""

        formatted = []
        for msg in messages:
            speaker = "User" if msg["is_user"] else "AI"
            formatted.append(f"{speaker}: {msg['message']}")

        return "\n".join(formatted)

    async def _update_conversation_summary(self, user_id):
        """최근 대화를 요약하여 저장합니다."""
        try:
            # 최근 20개 대화 가져오기
            recent_messages = chroma_db.get_recent_conversation_history(user_id, limit=20)

            if not recent_messages:
                return

            formatted_messages = self._format_messages(recent_messages)

            # 요약 프롬프트
            summary_prompt = f"""
            다음은 사용자와의 최근 대화입니다:

            {formatted_messages}

            이 대화의 핵심 내용을 200자 이내로 요약해주세요. 중요한 주제, 감정, 논의 사항을 포함하세요.
            """

            # 요약 생성
            response = await self.chat.ainvoke([
                SystemMessage(content="당신은 대화 내용을 간결하게 요약하는 전문가입니다."),
                HumanMessage(content=summary_prompt)
            ])

            # 요약본 저장
            chroma_db.save_conversation_summary(user_id, response.content)

            return response.content

        except Exception as e:
            logging.error(f"대화 요약 생성 오류: {str(e)}")
            return None

    def generate_response(self, message, user_id=None):
        """
        사용자 메시지에 대한 동기식 응답 생성 (chat_routes에서 사용)

        OpenAI API를 사용하여 응답을 생성합니다.
        """
        try:
            # 메시지 정제
            sanitized_message = self._sanitize_input(message)
            if not sanitized_message:
                return "메시지가 비어있거나 유효하지 않습니다."

            # 사용자 ID가 있는 경우 일일 제한 확인
            if user_id and not self._check_daily_limit(user_id):
                return "죄송합니다. 오늘의 대화 제한(100회)에 도달했습니다. 내일 다시 대화해주세요."

            # OpenAI API 직접 호출로 응답 생성
            try:
                # 최신 OpenAI API 형식 시도
                response = openai.chat.completions.create(
                    model="gpt-4o",
                    messages=[
                        {"role": "system", "content": "당신은 사용자와 대화하는 친절하고 공감적인 챗봇입니다."},
                        {"role": "user", "content": sanitized_message}
                    ],
                    temperature=0.1
                )

                # 응답 추출
                result = response.choices[0].message.content.strip()
            except AttributeError:
                # 이전 OpenAI API 형식 시도
                response = openai.ChatCompletion.create(
                    model="gpt-4o",
                    messages=[
                        {"role": "system", "content": "당신은 사용자와 대화하는 친절하고 공감적인 챗봇입니다."},
                        {"role": "user", "content": sanitized_message}
                    ],
                    temperature=0.1
                )

                # 응답 추출
                result = response.choices[0].message.content.strip()

            return result

        except Exception as e:
            # 오류 발생 시 기본 응답
            logging.error(f"응답 생성 오류: {str(e)}")
            return "죄송합니다. 응답을 생성하는 동안 오류가 발생했습니다."

    def generate_emotion_diary(self, chat_history):
        """
        채팅 기록을 바탕으로 감정을 어루만지는 감정 일기 생성
        """
        sanitized_history = self._sanitize_input(chat_history)

        prompt = f"""
        다음은 사용자와의 오늘 채팅 기록입니다:

        {sanitized_history}

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
        sanitized_history = self._sanitize_input(chat_history)

        prompt = f"""
        다음은 사용자와의 오늘 채팅 기록입니다:

        {sanitized_history}

        이 채팅 기록을 바탕으로 사용자의 행동과 활동을 객관적으로 분석하는 행동 일기를 작성해주세요.
        사실적이고 객관적인 표현을 사용하고, 사용자의 행동과 결정에 대해 분석하는 내용이어야 합니다.
        1인칭 시점으로 작성하며, 200자 이내로 요약해주세요.
        """

        response = self.generate_response(prompt)
        return response


# 전역 Chatbot 인스턴스
chatbot = Chatbot()