import logging
import os
import mysql.connector
from mysql.connector import Error


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

            # 이미 해당 날짜의 일기가 있는지 확인
            cursor.execute(
                "SELECT diary_id FROM diaries WHERE user_id = %s AND date = %s",
                (user_id, date)
            )
            existing_diary = cursor.fetchone()

            if existing_diary:
                # 기존 일기 업데이트
                cursor.execute(
                    "UPDATE diaries SET emotion_diary = %s, active_diary = %s WHERE id = %s",
                    (emotion_diary, active_diary, existing_diary['id'])
                )
            else:
                # 새 일기 삽입
                cursor.execute(
                    "INSERT INTO diaries (user_id, date, emotion_diary, active_diary, created_at) VALUES (%s, %s, %s, %s, NOW())",
                    (user_id, date, emotion_diary, active_diary)
                )

            conn.commit()
            return True
        except Exception as e:
            if conn:
                conn.rollback()
            logging.error(f"일기 저장 중 오류: {str(e)}")
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


# 전역 MySQL 인스턴스
mysql_db = MySQLDB()