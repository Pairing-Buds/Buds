from datetime import datetime
import logging
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
from db.mysql import mysql_db
from db.chroma import chroma_db
from core.chatbot import chatbot

# 로깅 설정
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(name)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class DiaryScheduler:
    def __init__(self):
        """일기 생성 스케줄러 초기화"""
        self.scheduler = BackgroundScheduler()
        # 오후 10시(22:00)에 실행되도록 설정
        self.scheduler.add_job(
            self.generate_and_save_diaries,
            trigger=CronTrigger(hour=22, minute=0),
            id='daily_diary_generation',
            replace_existing=True
        )
        logger.info("일기 생성 스케줄러가 초기화되었습니다.")

    def start(self):
        """스케줄러 시작"""
        self.scheduler.start()
        logger.info("일기 생성 스케줄러가 시작되었습니다.")

    def shutdown(self):
        """스케줄러 종료"""
        self.scheduler.shutdown()
        logger.info("일기 생성 스케줄러가 종료되었습니다.")

    async def generate_and_save_diaries(self):
        """모든 활성 사용자의 일기를 생성하고 저장"""
        try:
            logger.info("일일 일기 생성 작업 시작")

            # 활성 사용자 목록 가져오기
            active_users = mysql_db.get_active_users()

            if not active_users:
                logger.info("활성 사용자가 없습니다.")
                return

            # 오늘 날짜
            today = datetime.now().date().isoformat()

            # 각 사용자에 대해 일기 생성
            for user in active_users:
                user_id = user['id']

                try:
                    # 1. 사용자의 오늘 대화 내용 가져오기
                    collection = chroma_db.get_or_create_collection(user_id)

                    # 오늘 날짜의 대화만 필터링 (메타데이터에 날짜가 있다고 가정)
                    results = collection.get(
                        where={"date": today}
                    )

                    if not results or not results["documents"]:
                        logger.info(f"사용자 {user_id}의 오늘 채팅 기록이 없습니다.")
                        continue

                    # 2. 대화 내용 정리
                    conversations = []
                    for i, doc in enumerate(results["documents"]):
                        metadata = results["metadatas"][i]
                        conversations.append({
                            "text": doc,
                            "type": metadata["type"]
                        })

                    # 대화 텍스트 생성
                    chat_text = "\n".join(
                        [f"{'사용자' if conv['type'] == 'user' else '봇'}: {conv['text']}" for conv in conversations])

                    # 3. 감정 일기와 행동 일기 생성
                    emotion_diary = chatbot.generate_emotion_diary(chat_text)
                    active_diary = chatbot.generate_active_diary(chat_text)

                    # 4. 생성된 일기 저장
                    mysql_db.save_diary(
                        user_id=user_id,
                        date=today,
                        emotion_diary=emotion_diary,
                        active_diary=active_diary
                    )

                    logger.info(f"사용자 {user_id}의 일기가 성공적으로 생성되었습니다.")

                except Exception as e:
                    logger.error(f"사용자 {user_id}의 일기 생성 중 오류 발생: {str(e)}")
                    continue

            logger.info("일일 일기 생성 작업 완료")

        except Exception as e:
            logger.error(f"일기 생성 스케줄러 작업 중 오류 발생: {str(e)}")


# MySQL에 일기 저장 함수 추가 (db/mysql.py에 추가 필요)
"""
def save_diary(user_id, date, emotion_diary, active_diary):
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # 이미 해당 날짜의

        # 이미 해당 날짜의 일기가 있는지 확인
        cursor.execute(
            "SELECT id FROM diaries WHERE user_id = %s AND date = %s",
            (user_id, date)
        )
        existing_diary = cursor.fetchone()

        if existing_diary:
            # 기존 일기 업데이트
            cursor.execute(
                "UPDATE diaries SET emotion_diary = %s, active_diary = %s, updated_at = NOW() WHERE id = %s",
                (emotion_diary, active_diary, existing_diary['id'])
            )
        else:
            # 새 일기 삽입
            cursor.execute(
                "INSERT INTO diaries (user_id, date, emotion_diary, active_diary, created_at, updated_at) VALUES (%s, %s, %s, %s, NOW(), NOW())",
                (user_id, date, emotion_diary, active_diary)
            )

        conn.commit()
        return True
    except Exception as e:
        conn.rollback()
        logger.error(f"일기 저장 중 오류: {str(e)}")
        return False
    finally:
        cursor.close()
        conn.close()

def get_active_users():
    try:
        conn = get_connection()
        cursor = conn.cursor(dictionary=True)

        # 활성 사용자 가져오기
        # 예: 최근 7일 이내에 로그인한 사용자
        cursor.execute(
            "SELECT id FROM users WHERE last_login_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"
        )

        users = cursor.fetchall()
        return users
    except Exception as e:
        logger.error(f"활성 사용자 조회 중 오류: {str(e)}")
        return []
    finally:
        cursor.close()
        conn.close()
"""

# 앱 시작 시 스케줄러 초기화 및 시작
diary_scheduler = DiaryScheduler()

# 앱 시작 시 호출
def start_scheduler():
    diary_scheduler.start()

# 앱 종료 시 호출
def shutdown_scheduler():
    diary_scheduler.shutdown()

# 테스트 또는 수동 실행을 위한 함수
async def manual_generate_diaries():
    await diary_scheduler.generate_and_save_diaries()