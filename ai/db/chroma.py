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
        일관된 타임스탬프 형식을 사용하여 정렬 문제를 방지합니다.
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

            # 타임스탬프 생성 (ISO 8601 형식으로 통일)
            # 밀리초 단위까지 포함하여 정확한 순서 보장
            timestamp = datetime.now().isoformat(timespec='milliseconds')
            date_str = timestamp.split('T')[0]  # YYYY-MM-DD

            # 고유 ID 생성 (타임스탬프 기반, 사용자와 AI 메시지 구분)
            # 메시지 쌍이 순차적으로 저장되도록 ms 단위로 차이를 둠
            current_time_ms = int(datetime.now().timestamp() * 1000)
            user_id_str = f"user_{timestamp}_{current_time_ms}"
            ai_id_str = f"ai_{timestamp}_{current_time_ms + 1}"  # 1ms 차이

            # 사용자 메시지 저장
            user_metadata = {
                "type": "user",
                "timestamp": timestamp,
                "is_voice": is_voice,
                "date": date_str
            }

            collection.add(
                documents=[user_message],
                metadatas=[user_metadata],
                ids=[user_id_str]
            )

            logging.debug(f"사용자 메시지 저장: ID={user_id_str}, 타임스탬프={timestamp}")

            # AI 응답 저장
            ai_metadata = {
                "type": "ai",
                "timestamp": timestamp,  # 동일한 시간대 사용 (ms 단위 차이는 ID에만 반영)
                "is_voice": False,  # AI 응답은 항상 텍스트 (음성은 별도 처리)
                "date": date_str
            }

            collection.add(
                documents=[ai_response],
                metadatas=[ai_metadata],
                ids=[ai_id_str]
            )

            logging.debug(f"AI 메시지 저장: ID={ai_id_str}, 타임스탬프={timestamp}")

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


    def get_conversation_history_with_offset(self, user_id, limit=20, offset=0):
        """
        오프셋 기반으로 사용자의 대화 기록을 가져옵니다.
        반환값: (메시지 목록, 전체 메시지 수)
        """
        try:
            collection = self.get_or_create_collection(user_id)
            if collection is None:
                return [], 0

            # 전체 메시지 개수 확인
            try:
                total_count = collection.count()
                if total_count == 0:
                    return [], 0
            except Exception as count_err:
                logging.error(f"메시지 수 조회 오류: {str(count_err)}")
                return [], 0

            # 모든 메시지 가져오기 (ChromaDB는 직접적인 오프셋/페이지네이션 기능이 제한적)
            results = collection.get()

            if not results or not results["documents"]:
                return [], 0

            # 결과를 메시지 객체로 변환
            messages = []
            for i, doc in enumerate(results["documents"]):
                metadata = results["metadatas"][i]
                message_id = results["ids"][i]

                # 타임스탬프 처리 (일관성 보장)
                timestamp = metadata.get("timestamp", "")

                # 타임스탬프가 없거나 유효하지 않은 경우 대체 방법 시도
                if not timestamp or not isinstance(timestamp, str):
                    try:
                        # ID에서 타임스탬프 추출 시도 (user_2023-01-01T12:34:56 형식)
                        if "_" in message_id:
                            parts = message_id.split("_", 1)
                            if len(parts) > 1:
                                # ISO 형식 타임스탬프 추출 시도
                                timestamp_candidate = parts[1]
                                # 타임스탬프 유효성 검증
                                try:
                                    datetime.fromisoformat(timestamp_candidate.replace('Z', '+00:00'))
                                    timestamp = timestamp_candidate
                                except ValueError:
                                    # 유닉스 타임스탬프일 수도 있음
                                    if timestamp_candidate.replace('.', '').isdigit():
                                        try:
                                            dt = datetime.fromtimestamp(float(timestamp_candidate))
                                            timestamp = dt.isoformat()
                                        except (ValueError, OverflowError):
                                            # 변환 실패 시 현재 시간 사용
                                            timestamp = datetime.now().isoformat()
                                    else:
                                        # 추출 실패 시 현재 시간 사용
                                        timestamp = datetime.now().isoformat()
                            else:
                                # 분리 실패 시 현재 시간 사용
                                timestamp = datetime.now().isoformat()
                        else:
                            # ID 분리 불가 시 현재 시간 사용
                            timestamp = datetime.now().isoformat()
                    except Exception as ts_err:
                        logging.error(f"타임스탬프 추출 오류: {str(ts_err)}")
                        timestamp = datetime.now().isoformat()

                message = {
                    "message_id": message_id,
                    "message": doc,
                    "is_user": metadata.get("type", "") == "user",
                    "is_voice": metadata.get("is_voice", False),
                    "created_at": timestamp
                }
                messages.append(message)

            # 타임스탬프로 정렬 (오름차순 - 과거 -> 현재)
            try:
                # 안정적인 정렬을 위한 함수
                def get_timestamp_for_sorting(msg):
                    try:
                        # ISO 형식 타임스탬프 처리
                        return datetime.fromisoformat(msg["created_at"].replace('Z', '+00:00'))
                    except (ValueError, TypeError, AttributeError):
                        # 다른 형식이거나 오류 발생 시 기본값 반환
                        return datetime.min

                messages.sort(key=get_timestamp_for_sorting)
            except Exception as sort_err:
                logging.error(f"메시지 정렬 오류: {str(sort_err)}")
                # 정렬 실패 시 원본 순서 유지

            # 정렬 결과 로깅 (디버깅용)
            if messages:
                logging.debug(f"정렬된 메시지 예시 (처음 3개):")
                for i, msg in enumerate(messages[:3]):
                    logging.debug(f"  {i}: ID={msg['message_id']}, 시간={msg['created_at']}")

            # 오프셋과 한도를 적용하여 필요한 부분만 반환
            paginated_messages = messages[offset:offset + limit] if offset < len(messages) else []

            return paginated_messages, total_count

        except Exception as e:
            logging.error(f"대화 기록 조회 오류: {str(e)}")
            return [], 0

# 전역 ChromaDB 인스턴스
chroma_db = ChromaDB()