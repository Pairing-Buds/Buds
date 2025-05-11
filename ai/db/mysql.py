import logging
import os
import mysql.connector
from mysql.connector import Error


class MySQLDB:
    def __init__(self):
        try:
            # 환경 변수에서 데이터베이스 접속 정보 가져오기
            self.connection = mysql.connector.connect(
                host=os.getenv("DB_HOST", "k12c105.p.ssafy.io"),
                port=os.getenv("DB_PORT", "3306"),
                user=os.getenv("DB_USER", "Pairing"),
                password=os.getenv("DB_PASSWORD", "ssafyC105PairingBuds"),
                database=os.getenv("DB_NAME", "Buds")
            )

            if self.connection.is_connected():
                logging.info("MySQL 데이터베이스 연결 성공")
        except Error as e:
            logging.error(f"MySQL 연결 오류: {str(e)}")
            self.connection = None
            raise ValueError(f"데이터베이스 연결 실패: {str(e)}")

    def get_user_profile(self, user_id):
        """
        사용자 프로필 정보 조회
        데이터베이스 연결 실패나 사용자를 찾지 못하는 경우 예외 발생
        """
        try:
            if self.connection is None or not self.connection.is_connected():
                raise ValueError("MySQL 데이터베이스 연결이 없습니다")

            cursor = self.connection.cursor(dictionary=True)
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


# 전역 MySQL 인스턴스
mysql_db = MySQLDB()