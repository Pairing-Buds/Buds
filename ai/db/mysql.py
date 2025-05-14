import logging
import os
import mysql.connector
from mysql.connector import Error
from datetime import datetime

class MySQLDB:
    def __init__(self):
        try:
            # 환경 변수에서 데이터베이스 접속 정보 가져오기
            self.connection = mysql.connector.connect(
                host=os.getenv("MYSQL_HOST"),
                port=os.getenv("MYSQL_PORT"),
                user=os.getenv("MYSQL_USERNAME"),
                password=os.getenv("MYSQL_PASSWORD"),
                database=os.getenv("MYSQL_DATABASE")
            )

            if self.connection.is_connected():
                logging.info("MySQL 데이터베이스 연결 성공")
        except Error as e:
            logging.error(f"MySQL 연결 오류: {str(e)}")
            self.connection = None
            raise ValueError(f"데이터베이스 연결 실패: {str(e)}")

    def get_connection(self):
        """
        데이터베이스 연결을 반환하는 메서드
        연결이 끊어진 경우 재연결 시도
        """
        try:
            if self.connection is None or not self.connection.is_connected():
                # 연결이 없거나 끊어진 경우 재연결
                self.connection = mysql.connector.connect(
                    host=os.getenv("MYSQL_HOST"),
                    port=os.getenv("MYSQL_PORT"),
                    user=os.getenv("MYSQL_USERNAME"),
                    password=os.getenv("MYSQL_PASSWORD"),
                    database=os.getenv("MYSQL_DATABASE")
                )
                logging.info("MySQL 데이터베이스 재연결 성공")

            return self.connection
        except Error as e:
            logging.error(f"MySQL 연결 오류: {str(e)}")
            raise ValueError(f"데이터베이스 연결 실패: {str(e)}")

    def get_user_profile(self, user_id):
        """
        사용자 프로필 정보 조회
        데이터베이스 연결 실패나 사용자를 찾지 못하는 경우 예외 발생
        """
        try:
            conn = self.get_connection()
            cursor = conn.cursor(dictionary=True)
            query = "SELECT * FROM users WHERE user_id = %s"
            cursor.execute(query, (user_id,))
            user = cursor.fetchone()
            cursor.close()

            if user is None:
                raise ValueError(f"사용자 ID {user_id}를 찾을 수 없습니다")

            return user

        except Error as e:
            logging.error(f"사용자 프로필 조회 오류: {str(e)}")
            raise ValueError(f"데이터베이스 오류: {str(e)}")

    def close(self):
        """데이터베이스 연결 종료"""
        try:
            if self.connection and self.connection.is_connected():
                self.connection.close()
                logging.info("MySQL 연결 종료")
        except Error as e:
            logging.error(f"MySQL 연결 종료 오류: {str(e)}")

    def save_diary(self, user_id, date, emotion_diary, active_diary):
        """
        사용자의 감정 일기와 활동 일기를 저장하는 메서드
        이미 존재하는 일기는 업데이트하고, 없는 경우 새로 생성
        """
        conn = None
        cursor = None
        try:
            conn = self.get_connection()
            cursor = conn.cursor(dictionary=True)

            # 날짜 부분만 추출 (시간 정보 제거)
            if isinstance(date, str):
                try:
                    # 날짜 문자열에서 날짜 부분만 추출
                    date_only = datetime.strptime(date, '%Y-%m-%d').date()
                except ValueError:
                    try:
                        # ISO 형식이나 다른 형식의 날짜 처리
                        date_only = datetime.fromisoformat(date).date()
                    except:
                        # 마지막 방어책: 현재 날짜 사용
                        date_only = datetime.now().date()
            else:
                # datetime 객체인 경우 날짜 부분만 추출
                date_only = date.date() if hasattr(date, 'date') else datetime.now().date()

            # 날짜만 있는 문자열 생성 (YYYY-MM-DD)
            date_str = date_only.strftime('%Y-%m-%d')

            # 날짜만 있는 datetime 생성 (시간은 00:00:00으로 설정)
            date_time_str = f"{date_str} 00:00:00"

            logging.info(f"일기 저장: 사용자={user_id}, 날짜={date_str}")

            # 이미 해당 날짜의 일기가 있는지 확인 (날짜 부분만 비교)
            cursor.execute(
                "SELECT diary_id FROM diaries WHERE user_id = %s AND DATE(date) = %s",
                (user_id, date_str)
            )
            existing_diary = cursor.fetchone()

            if existing_diary:
                # 기존 일기 업데이트
                cursor.execute(
                    "UPDATE diaries SET emotion_diary = %s, active_diary = %s WHERE diary_id = %s",
                    (emotion_diary, active_diary, existing_diary['diary_id'])
                )
                logging.info(f"기존 일기 업데이트: diary_id={existing_diary['diary_id']}")
            else:
                # 새 일기 삽입 - 날짜만 있는 datetime 값 사용 (시간은 00:00:00)
                cursor.execute(
                    "INSERT INTO diaries (user_id, date, emotion_diary, active_diary, created_at) VALUES (%s, %s, %s, %s, NOW())",
                    (user_id, date_time_str, emotion_diary, active_diary)
                )
                new_id = cursor.lastrowid
                logging.info(f"새 일기 생성: diary_id={new_id}, 날짜={date_time_str}")

            conn.commit()
            return True
        except Exception as e:
            if conn:
                conn.rollback()
            logging.error(f"일기 저장 오류: {str(e)}")
            return False
        finally:
            if cursor:
                cursor.close()

    def get_active_users(self):
        """
        최근 7일 이내에 로그인한 활성 사용자 목록 반환
        """
        conn = None
        cursor = None
        try:
            conn = self.get_connection()
            cursor = conn.cursor(dictionary=True)

            # 활성 사용자 가져오기
            # 예: 최근 7일 이내에 로그인한 사용자
            cursor.execute(
                "SELECT user_id, user_name, user_email FROM users WHERE updated_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)"
            )

            users = cursor.fetchall()
            return users
        except Exception as e:
            logging.error(f"활성 사용자 조회 중 오류: {str(e)}")
            return []
        finally:
            if cursor:
                cursor.close()

    def save_calendar_emotion_badge(self, user_id: int, date: str, emotion_group: str):
        try:
            conn = self.get_connection()
            cursor = conn.cursor()

            # 1. calendar_id 확인 또는 생성
            cursor.execute("""
                SELECT calendar_id FROM calendars
                WHERE user_id = %s AND date = %s
            """, (user_id, date))
            row = cursor.fetchone()

            if row:
                calendar_id = row[0]
            else:
                cursor.execute("""
                    INSERT INTO calendars (user_id, date, created_at)
                    VALUES (%s, %s, NOW())
                """, (user_id, date))
                calendar_id = cursor.lastrowid

            # 2. badge_id 가져오기
            EMOTION_GROUP_MAPPING = {
                '기쁨': 'JOY',
                '슬픔': 'SADNESS',
                '분노': 'ANGER',
                '불안': 'FEAR',
                '혐오': 'DISGUST',
                '놀람': 'SURPRISE',
                '중립': 'NEUTRAL'
            }
            emotion_group = EMOTION_GROUP_MAPPING.get(emotion_group, emotion_group.upper())

            cursor.execute("""
                           INSERT INTO badges (badge_type, name)
                           VALUES (0, %s)
                           """, (emotion_group,))
            badge_id = cursor.lastrowid  # 새로 생성된 badge_id 가져오기

            # 3. 중복 삽입 방지 후 저장
            cursor.execute("""
                SELECT 1 FROM calendar_badges WHERE calendar_id = %s
                AND badge_id = %s
            """, (calendar_id, badge_id))
            if cursor.fetchone() is None:
                cursor.execute("""
                    INSERT INTO calendar_badges (calendar_id, badge_id)
                    VALUES (%s, %s)
            """, (calendar_id, badge_id))

            conn.commit()
            logging.info(f"🎉 감정 뱃지 [{emotion_group}] 저장 완료")

        except Exception as e:
            if conn:
                conn.rollback()
            logging.error(f"감정 뱃지 저장 오류: {str(e)}")
        finally:
            cursor.close()


# 전역 MySQL 인스턴스
mysql_db = MySQLDB()