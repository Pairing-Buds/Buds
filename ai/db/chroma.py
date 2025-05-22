import logging
from datetime import datetime, timedelta
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
            # 입력값 검증
            if not user_message or not isinstance(user_message, str):
                user_message = ""
            if not ai_response or not isinstance(ai_response, str):
                ai_response = ""

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
                "is_voice": is_voice,  # 음성 메시지 여부 저장
                "date": timestamp.split('T')[0]  # 날짜 부분만 저장(YYYY-MM-DD)
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
                "is_voice": False,  # AI 응답은 항상 텍스트
                "date": timestamp.split('T')[0]  # 날짜 부분만 저장(YYYY-MM-DD)
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
            # 입력값 검증
            if not query or not isinstance(query, str):
                return ""

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
            except Exception as count_err:
                logging.info(f"컬렉션 항목 수 확인 중 오류: {str(count_err)}. 빈 컬렉션으로 가정합니다.")
                return ""

            # 쿼리 실행 (최소 2개 이상의 단어가 있는 경우에만)
            if len(query.split()) >= 2:
                # 쿼리 결과 (비어있을 수 있음)
                results = collection.query(
                    query_texts=[query],
                    n_results=min(limit, count)
                )

                # 결과를 포맷팅하여 반환
                if results and results["documents"] and results["documents"][0]:
                    # 메타데이터 정보와 함께 결과 형식화
                    formatted_results = []
                    for i, doc in enumerate(results["documents"][0]):
                        meta = results["metadatas"][0][i] if i < len(results["metadatas"][0]) else {"type": "unknown"}
                        speaker = "User" if meta.get("type") == "user" else "AI"
                        formatted_results.append(f"{speaker}: {doc}")

                    return "\n".join(formatted_results)

            # 쿼리 결과가 없거나 단어가 적은 경우 빈 문자열 반환
            return ""

        except Exception as e:
            logging.error(f"유사 대화 검색 오류: {str(e)}")
            return ""

    def get_recent_conversation_history(self, user_id, limit=15):
        """사용자의 최근 대화 기록을 시간순으로 가져옵니다."""
        try:
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                return []

            # 컬렉션이 비어있는지 확인
            try:
                count = collection.count()
                if count == 0:
                    return []
            except:
                return []

            # 최대 항목 수를 확인하여 과도한 요청 방지
            actual_limit = min(limit * 2, 200)  # 최대 100개 대화쌍(200개 메시지) 제한

            # 모든 메시지 가져오기
            results = collection.get(limit=actual_limit)

            if not results or not results["documents"]:
                return []

            # 결과를 메시지 목록으로 변환
            messages = []
            for i, doc in enumerate(results["documents"]):
                metadata = results["metadatas"][i]
                created_at = metadata.get("timestamp", "")

                message_data = {
                    "message": doc,
                    "is_user": metadata["type"] == "user",
                    "created_at": created_at,
                    "is_voice": metadata.get("is_voice", False)
                }

                messages.append(message_data)

            # 시간순 정렬
            try:
                messages.sort(key=lambda x: x["created_at"])
            except Exception as sort_err:
                logging.error(f"메시지 정렬 오류: {str(sort_err)}")
                # 정렬 실패 시 원본 순서 유지

            # 최근 메시지만 반환
            return messages[-limit:]

        except Exception as e:
            logging.error(f"최근 대화 기록 조회 오류: {str(e)}")
            return []

    def get_conversation_summary(self, user_id):
        """사용자의 대화 요약을 가져옵니다."""
        try:
            summary_collection = self.get_or_create_collection(f"{user_id}_summary")
            if summary_collection is None:
                return ""

            try:
                count = summary_collection.count()
                if count == 0:
                    return ""
            except:
                return ""

            results = summary_collection.get(limit=1)

            if not results or not results["documents"] or not results["documents"][0]:
                return ""

            return results["documents"][0]
        except Exception as e:
            logging.error(f"대화 요약 조회 오류: {str(e)}")
            return ""

    def save_conversation_summary(self, user_id, summary):
        """사용자의 대화 요약을 저장합니다."""
        try:
            # 입력값 검증
            if not summary or not isinstance(summary, str):
                return False

            summary_collection = self.get_or_create_collection(f"{user_id}_summary")
            if summary_collection is None:
                return False

            # 기존 요약 삭제 시도
            try:
                existing_results = summary_collection.get()
                if existing_results and existing_results["ids"]:
                    summary_collection.delete(ids=existing_results["ids"])
            except Exception as del_err:
                logging.warning(f"기존 요약 삭제 중 오류(무시됨): {str(del_err)}")

            # 새 요약 저장
            summary_collection.add(
                documents=[summary],
                metadatas=[{
                    "type": "summary",
                    "timestamp": datetime.now().isoformat(),
                    "date": datetime.now().strftime('%Y-%m-%d')
                }],
                ids=[f"summary_{datetime.now().timestamp()}"]
            )

            return True
        except Exception as e:
            logging.error(f"대화 요약 저장 오류: {str(e)}")
            return False

    def get_message_count(self, user_id):
        """사용자의 총 메시지 수를 반환합니다."""
        try:
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                return 0

            # 사용자 메시지만 카운트
            results = collection.get(
                where={"type": "user"}
            )

            if not results or not results["documents"]:
                return 0

            return len(results["documents"])
        except Exception as e:
            logging.error(f"메시지 카운트 오류: {str(e)}")
            return 0

    def get_daily_message_count(self, user_id, date_str):
        """특정 날짜의 사용자 메시지 수를 반환합니다."""
        try:
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                return 0

            # 직접 date 필드로 필터링 시도
            try:
                results = collection.get(
                    where={
                        "$and": [
                            {"date": date_str},
                            {"type": "user"}  # 사용자 메시지만 카운트
                        ]
                    }
                )

                if results and results["documents"]:
                    return len(results["documents"])
            except Exception as where_err:
                logging.warning(f"날짜 필터링 오류, 대체 방법 시도: {str(where_err)}")

            # 날짜 필터링이 실패한 경우 전체 메시지를 가져와서 날짜별로 필터링
            all_results = collection.get(
                where={"type": "user"}  # 사용자 메시지만 가져오기
            )

            if not all_results or not all_results["documents"]:
                return 0

            # 메타데이터에서 타임스탬프 추출하여 해당 날짜의 메시지만 카운트
            count = 0
            for metadata in all_results["metadatas"]:
                try:
                    msg_date = metadata.get("timestamp", "").split("T")[0]
                    if msg_date == date_str:
                        count += 1
                except:
                    continue

            return count

        except Exception as e:
            logging.error(f"일일 메시지 수 조회 오류: {str(e)}")
            return 0

    def clean_old_conversations(self, days_to_keep=30):
        """오래된 대화를 정리합니다. 지정된 일수보다 오래된 대화는 삭제됩니다."""
        try:
            # 모든 컬렉션 가져오기
            collections = self.client.list_collections()

            # 삭제 기준 날짜 계산
            cutoff_date = datetime.now() - timedelta(days=days_to_keep)
            cutoff_timestamp = cutoff_date.isoformat()

            cleaned_count = 0

            for collection_info in collections:
                collection_name = collection_info.name
                # 요약 컬렉션은 건너뛰기
                if "_summary" in collection_name:
                    continue

                collection = self.client.get_collection(name=collection_name)

                # 오래된 메시지 검색
                try:
                    old_messages = collection.get(
                        where={"timestamp": {"$lt": cutoff_timestamp}}
                    )

                    if old_messages and old_messages["ids"]:
                        # 오래된 메시지 삭제
                        collection.delete(ids=old_messages["ids"])
                        cleaned_count += len(old_messages["ids"])
                except Exception as col_err:
                    logging.error(f"컬렉션 {collection_name} 정리 중 오류: {str(col_err)}")
                    continue

            logging.info(f"대화 정리 완료: {cleaned_count}개 오래된 메시지 삭제됨")
            return cleaned_count

        except Exception as e:
            logging.error(f"대화 정리 중 오류: {str(e)}")
            return 0

    def export_user_conversations(self, user_id, start_date=None, end_date=None):
        """
        사용자의 대화 기록을 내보냅니다.
        선택적으로 시작 및 종료 날짜를 지정하여 특정 기간의 대화만 내보낼 수 있습니다.
        """
        try:
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                return []

            # 날짜 필터링을 위한 조건 준비
            where_condition = {}

            if start_date and end_date:
                # ISO 형식으로 변환
                start_iso = datetime.strptime(start_date, '%Y-%m-%d').isoformat()
                # 종료일은 다음날로 설정하여 해당일까지 포함
                end_iso = (datetime.strptime(end_date, '%Y-%m-%d') + timedelta(days=1)).isoformat()

                where_condition = {
                    "timestamp": {
                        "$gte": start_iso,
                        "$lt": end_iso
                    }
                }

                # 날짜 조건으로 쿼리
                results = collection.get(where=where_condition)
            else:
                # 모든 메시지 가져오기
                results = collection.get()

            if not results or not results["documents"]:
                return []

            # 대화 형식화
            conversations = []
            for i, doc in enumerate(results["documents"]):
                meta = results["metadatas"][i]
                timestamp = meta.get("timestamp", "")

                conversation = {
                    "message": doc,
                    "is_user": meta.get("type") == "user",
                    "timestamp": timestamp,
                    "is_voice": meta.get("is_voice", False)
                }

                conversations.append(conversation)

            # 시간순 정렬
            conversations.sort(key=lambda x: x["timestamp"])

            return conversations

        except Exception as e:
            logging.error(f"대화 내보내기 오류: {str(e)}")
            return []


# 전역 ChromaDB 인스턴스
chroma_db = ChromaDB()