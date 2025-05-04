from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
import logging
import os
from db.mysql import mysql_db
from db.chroma import chroma_db
from core.prompts import generate_system_prompt


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


# 전역 Chatbot 인스턴스
chatbot = Chatbot()