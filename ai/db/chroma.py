import logging
import os
from datetime import datetime, timezone, timedelta
import chromadb
from chromadb.config import Settings

# 한국 시간대(KST) 정의 - UTC+9
KST = timezone(timedelta(hours=9))


def get_kst_now():
    """현재 시간을 한국 표준시(KST)로 반환"""
    return datetime.now(KST)


class ChromaDB:
    def __init__(self):
        try:
            # 데이터 저장 경로 설정 (환경 변수 또는 기본값 사용)
            db_path = os.getenv("CHROMA_DB_PATH", "./chroma_db")

            # 디렉토리 존재 확인 및 생성 (필요 시)
            os.makedirs(db_path, exist_ok=True)
            logging.info(f"ChromaDB 데이터 저장 경로: {os.path.abspath(db_path)}")

            # 설정 구성
            settings = Settings(
                anonymized_telemetry=False,  # 텔레메트리 비활성화 (선택 사항)
                persist_directory=db_path,  # 데이터 저장 디렉토리
                chroma_db_impl="duckdb+parquet"  # 기본 스토리지 백엔드
            )

            # 로컬 파일 시스템 기반 클라이언트 초기화
            self.client = chromadb.PersistentClient(
                path=db_path,
                settings=settings
            )

            logging.info(f"ChromaDB 로컬 클라이언트 초기화 성공")

            # 연결 테스트
            collections = self.client.list_collections()
            logging.info(f"ChromaDB 컬렉션 확인: {len(collections)}개 컬렉션 존재")

        except Exception as e:
            logging.error(f"ChromaDB 초기화 실패: {str(e)}")

            # 메모리 기반 클라이언트로 폴백 (데이터는 애플리케이션 종료 시 손실됨)
            try:
                logging.warning("메모리 기반 ChromaDB 클라이언트로 전환합니다.")
                self.client = chromadb.EphemeralClient()
                logging.warning("메모리 기반 ChromaDB 클라이언트 초기화 성공")
            except Exception as e2:
                logging.error(f"메모리 기반 ChromaDB 초기화 실패: {str(e2)}")
                self.client = None
                logging.error("ChromaDB 클라이언트 초기화 완전 실패")

    def get_or_create_collection(self, user_id):
        """사용자별 컬렉션을 가져오거나 생성"""
        collection_name = f"user_{user_id}_conversations"

        # 컬렉션 존재 여부 확인 및 생성
        try:
            # 기존 컬렉션 로드 시도
            try:
                collection = self.client.get_collection(name=collection_name)
                logging.debug(f"기존 컬렉션 로드 성공: {collection_name}")
                return collection
            except Exception:
                logging.debug(f"컬렉션 로드 실패, 생성 시도: {collection_name}")

            # 컬렉션 생성 시도
            collection = self.client.create_collection(name=collection_name)
            logging.info(f"새 컬렉션 생성 성공: {collection_name}")
            return collection

        except Exception as e:
            logging.error(f"컬렉션 생성 오류: {str(e)}")
            raise ValueError(f"컬렉션 생성 실패: {str(e)}")

    def save_conversation(self, user_id, user_message, ai_response, is_voice=False, timestamp=None):
        """
        사용자와 AI의 대화 내용을 저장합니다.
        timestamp 매개변수를 통해 명시적인 시간 지정 가능 (KST 기준)
        """
        # 입력값 검증
        if not user_message or not isinstance(user_message, str):
            user_message = ""
        if not ai_response or not isinstance(ai_response, str):
            ai_response = ""

        # 시간 설정 (timestamp가 None이면 현재 KST 시간 사용)
        if timestamp is None:
            timestamp = get_kst_now()
        elif timestamp.tzinfo is None:
            # 시간대 정보가 없으면 KST로 가정
            timestamp = timestamp.replace(tzinfo=KST)

        # 컬렉션 가져오기
        collection = self.get_or_create_collection(user_id)

        # 타임스탬프 생성 (ISO 8601 형식으로 통일)
        timestamp_iso = timestamp.isoformat(timespec='milliseconds')
        date_str = timestamp.strftime('%Y-%m-%d')  # YYYY-MM-DD

        # 고유 ID 생성
        current_time_ms = int(timestamp.timestamp() * 1000)
        user_id_str = f"user_{timestamp_iso}_{current_time_ms}"
        ai_id_str = f"ai_{timestamp_iso}_{current_time_ms + 1}"  # 1ms 차이

        # 사용자 메시지 저장
        user_metadata = {
            "type": "user",
            "timestamp": timestamp_iso,
            "is_voice": is_voice,
            "date": date_str,
            "timezone": "KST",  # 명시적인 시간대 정보 추가
        }

        collection.add(
            documents=[user_message],
            metadatas=[user_metadata],
            ids=[user_id_str]
        )

        # AI 응답 저장
        ai_metadata = {
            "type": "ai",
            "timestamp": timestamp_iso,
            "is_voice": False,
            "date": date_str,
            "timezone": "KST",  # 명시적인 시간대 정보 추가
        }

        collection.add(
            documents=[ai_response],
            metadatas=[ai_metadata],
            ids=[ai_id_str]
        )

        return True

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

    def get_recent_conversation_history(self, user_id, limit=15, timezone=None):
        """
        사용자의 최근 대화 기록을 시간순으로 가져옵니다.
        timezone 매개변수를 통해 결과의 시간대 지정 가능
        """
        try:
            # 기본 시간대는 KST
            if timezone is None:
                timezone = KST

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

                # 타임스탬프 처리 (시간대 정보 추가)
                created_at = metadata.get("timestamp", "")

                # 시간 문자열을 datetime 객체로 변환하고 시간대 적용
                try:
                    if created_at:
                        dt = datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                        if dt.tzinfo is None:
                            # ISO 형식이지만 시간대 정보가 없는 경우
                            stored_timezone = metadata.get("timezone")
                            if stored_timezone == "KST":
                                dt = dt.replace(tzinfo=KST)
                            else:
                                # 기본적으로 UTC 가정
                                dt = dt.replace(tzinfo=timezone.utc)

                        # 지정된 시간대로 변환
                        dt = dt.astimezone(timezone)
                        created_at = dt.isoformat()
                except (ValueError, TypeError):
                    # 파싱 오류 시 원래 문자열 사용
                    pass

                message_data = {
                    "message": doc,
                    "is_user": metadata["type"] == "user",
                    "created_at": created_at,
                    "is_voice": metadata.get("is_voice", False)
                }

                messages.append(message_data)

            # 시간순 정렬
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

            # 현재 KST 시간
            now = get_kst_now()

            # 기존 요약 삭제 시도
            try:
                existing_results = summary_collection.get()
                if existing_results and existing_results["ids"]:
                    summary_collection.delete(ids=existing_results["ids"])
            except Exception as del_err:
                logging.warning(f"기존 요약 삭제 중 오류(무시됨): {str(del_err)}")

            # 새 요약 저장 (KST 시간 사용)
            summary_collection.add(
                documents=[summary],
                metadatas=[{
                    "type": "summary",
                    "timestamp": now.isoformat(),
                    "date": now.strftime('%Y-%m-%d'),
                    "timezone": "KST"
                }],
                ids=[f"summary_{now.timestamp()}"]
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
                    msg_date = metadata.get("date", "")
                    if not msg_date and "timestamp" in metadata:
                        # timestamp에서 날짜 부분 추출
                        msg_date = metadata.get("timestamp", "").split("T")[0]
                    if msg_date == date_str:
                        count += 1
                except:
                    continue

            return count

        except Exception as e:
            logging.error(f"일일 메시지 수 조회 오류: {str(e)}")
            return 0

    def get_conversation_history_with_offset(self, user_id, limit=20, offset=0, timezone=None):
        """
        오프셋 기반으로 사용자의 대화 기록을 가져옵니다.
        timezone 매개변수를 통해 결과의 시간대 지정 가능
        반환값: (메시지 목록, 전체 메시지 수)
        """
        try:
            # 기본 시간대는 KST
            if timezone is None:
                timezone = KST

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

                # 타임스탬프 처리 (시간대 정보 추가)
                timestamp_str = metadata.get("timestamp", "")

                # 시간 문자열을 datetime 객체로 변환하고 시간대 적용
                try:
                    if timestamp_str:
                        dt = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
                        if dt.tzinfo is None:
                            # ISO 형식이지만 시간대 정보가 없는 경우
                            stored_timezone = metadata.get("timezone")
                            if stored_timezone == "KST":
                                dt = dt.replace(tzinfo=KST)
                            else:
                                # 기본적으로 UTC 가정
                                dt = dt.replace(tzinfo=timezone.utc)

                        # 지정된 시간대로 변환
                        dt = dt.astimezone(timezone)
                        timestamp_str = dt.strftime('%Y-%m-%d %H:%M:%S')
                except (ValueError, TypeError):
                    # 파싱 오류 시 원래 문자열 사용
                    pass

                # 타임스탬프가 없거나 유효하지 않은 경우 ID에서 추출 시도
                if not timestamp_str or not isinstance(timestamp_str, str):
                    try:
                        # ID에서 타임스탬프 추출 시도 (user_2023-01-01T12:34:56 형식)
                        if "_" in message_id:
                            parts = message_id.split("_", 1)
                            if len(parts) > 1:
                                # ISO 형식 타임스탬프 추출 시도
                                timestamp_candidate = parts[1]
                                try:
                                    dt = datetime.fromisoformat(timestamp_candidate.replace('Z', '+00:00'))
                                    if dt.tzinfo is None:
                                        dt = dt.replace(tzinfo=timezone.utc)
                                    dt = dt.astimezone(timezone)
                                    timestamp_str = dt.strftime('%Y-%m-%d %H:%M:%S')
                                except ValueError:
                                    # 유닉스 타임스탬프일 수도 있음
                                    if timestamp_candidate.replace('.', '').isdigit():
                                        try:
                                            dt = datetime.fromtimestamp(float(timestamp_candidate), tz=timezone)
                                            timestamp_str = dt.strftime('%Y-%m-%d %H:%M:%S')
                                        except (ValueError, OverflowError):
                                            # 변환 실패 시 현재 KST 시간 사용
                                            timestamp_str = get_kst_now().strftime('%Y-%m-%d %H:%M:%S')
                                    else:
                                        # 추출 실패 시 현재 KST 시간 사용
                                        timestamp_str = get_kst_now().strftime('%Y-%m-%d %H:%M:%S')
                            else:
                                # 분리 실패 시 현재 KST 시간 사용
                                timestamp_str = get_kst_now().strftime('%Y-%m-%d %H:%M:%S')
                        else:
                            # ID 분리 불가 시 현재 KST 시간 사용
                            timestamp_str = get_kst_now().strftime('%Y-%m-%d %H:%M:%S')
                    except Exception as ts_err:
                        logging.error(f"타임스탬프 추출 오류: {str(ts_err)}")
                        timestamp_str = get_kst_now().strftime('%Y-%m-%d %H:%M:%S')

                message = {
                    "message_id": message_id,
                    "message": doc,
                    "is_user": metadata.get("type", "") == "user",
                    "is_voice": metadata.get("is_voice", False),
                    "created_at": timestamp_str
                }
                messages.append(message)

            # 타임스탬프로 정렬 (오름차순 - 과거 -> 현재)
            try:
                # 안정적인 정렬을 위한 함수
                def get_timestamp_for_sorting(msg):
                    try:
                        # 문자열 형식 타임스탬프 처리 (YYYY-MM-DD HH:MM:SS)
                        created_at = msg["created_at"]
                        if 'T' in created_at:
                            # ISO 형식
                            return datetime.fromisoformat(created_at.replace('Z', '+00:00'))
                        else:
                            # YYYY-MM-DD HH:MM:SS 형식
                            dt = datetime.strptime(created_at, '%Y-%m-%d %H:%M:%S')
                            return dt.replace(tzinfo=timezone)
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