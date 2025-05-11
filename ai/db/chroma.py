import logging
from datetime import datetime
import chromadb
from chromadb.config import Settings


class ChromaDB:
    def __init__(self):
        try:
            # 최신 버전의 ChromaDB 클라이언트 초기화
            self.client = chromadb.PersistentClient(path="./chroma_db")
            logging.info("ChromaDB 연결 성공")
        except Exception as e:
            logging.error(f"ChromaDB 연결 실패: {str(e)}")
            # 메모리 기반 클라이언트로 폴백
            try:
                self.client = chromadb.EphemeralClient()
                logging.warning("메모리 기반 ChromaDB 클라이언트를 사용합니다.")
            except Exception as e2:
                logging.error(f"메모리 기반 ChromaDB 초기화 실패: {str(e2)}")
                self.client = None

    def get_or_create_collection(self, user_id):
        """사용자별 컬렉션을 가져오거나 생성"""
        try:
            if self.client is None:
                logging.error("ChromaDB 클라이언트가 초기화되지 않았습니다.")
                return None

            collection_name = f"user_{user_id}_conversations"
            collection = self.client.get_or_create_collection(name=collection_name)
            return collection
        except Exception as e:
            logging.error(f"컬렉션 생성 오류: {str(e)}")
            return None

    def save_conversation(self, user_id, user_message, ai_response, is_voice=False):
        """
        사용자와 AI의 대화 내용을 저장합니다.
        is_voice 파라미터를 추가하여 음성 메시지 여부를 표시합니다.
        """
        try:
            # 컬렉션 가져오기
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                logging.error(f"사용자 ID {user_id}의 컬렉션을 가져올 수 없습니다.")
                return False

            # 타임스탬프 생성
            timestamp = datetime.now().isoformat()

            # 사용자 메시지 저장
            user_metadata = {
                "type": "user",
                "timestamp": timestamp,
                "is_voice": is_voice  # 음성 메시지 여부 저장
            }
            collection.add(
                documents=[user_message],
                metadatas=[user_metadata],
                ids=[f"user_{timestamp}"]
            )

            # AI 응답 저장
            ai_metadata = {
                "type": "ai",
                "timestamp": timestamp,
                "is_voice": False  # AI 응답은 항상 텍스트
            }
            collection.add(
                documents=[ai_response],
                metadatas=[ai_metadata],
                ids=[f"ai_{timestamp}"]
            )

            return True
        except Exception as e:
            logging.error(f"대화 저장 중 오류: {str(e)}")
            return False

    def get_similar_conversations(self, user_id, query, limit=5):
        """사용자의 이전 대화 중 현재 쿼리와 유사한 대화를 검색"""
        try:
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                logging.error(f"사용자 ID {user_id}의 컬렉션을 가져올 수 없습니다.")
                return ""

            # 컬렉션에 항목이 있는지 확인
            try:
                count = collection.count()
                if count == 0:
                    logging.info(f"사용자 ID {user_id}의 컬렉션이 비어 있습니다.")
                    return ""
            except:
                logging.info(f"컬렉션 항목 수 확인 중 오류. 빈 컬렉션으로 가정합니다.")
                return ""

            # 쿼리 결과 (비어있을 수 있음)
            results = collection.query(
                query_texts=[query],
                n_results=min(limit, count)
            )

            # 결과가 있으면 텍스트 반환, 없으면 빈 문자열
            if results and results["documents"] and results["documents"][0]:
                return "\n".join(results["documents"][0])
            else:
                return ""

        except Exception as e:
            logging.error(f"유사 대화 검색 오류: {str(e)}")
            return ""


# 전역 ChromaDB 인스턴스
chroma_db = ChromaDB()