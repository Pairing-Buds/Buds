import chromadb
from chromadb.utils.embedding_functions import OpenAIEmbeddingFunction
import logging
import uuid
import os


class ChromaDBConnection:
    def __init__(self):
        # 단순 Persistent 클라이언트로 변경 (HTTP 서버 없이 로컬 인스턴스로 실행)
        self.client = chromadb.PersistentClient(path="./chroma_data")

        # API 키 가져오기
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")

        self.embedder = OpenAIEmbeddingFunction(api_key=api_key)
        logging.info("ChromaDB 클라이언트가 로컬 모드로 초기화되었습니다.")

    def get_or_create_collection(self, user_id):
        """사용자별 컬렉션을 가져오거나 생성합니다."""
        collection_name = f"user_{user_id}"
        return self.client.get_or_create_collection(
            name=collection_name,
            embedding_function=self.embedder
        )

    def get_similar_conversations(self, user_id, message, n_results=3):
        """현재 메시지와 유사한 과거 대화를 검색합니다."""
        collection = self.get_or_create_collection(user_id)
        results = collection.query(
            query_texts=[message],
            n_results=n_results,
            where={"type": "user"}
        )
        return results

    def save_conversation(self, user_id, user_message, ai_message):
        """사용자와 AI 메시지를 저장합니다."""
        collection = self.get_or_create_collection(user_id)
        collection.add(
            documents=[user_message, ai_message],
            metadatas=[
                {"type": "user"},
                {"type": "ai"}
            ],
            ids=[str(uuid.uuid4()), str(uuid.uuid4())]
        )
        logging.info(f"사용자 {user_id}의 대화가 저장되었습니다.")


# 전역 ChromaDB 연결 인스턴스
chroma_db = ChromaDBConnection()