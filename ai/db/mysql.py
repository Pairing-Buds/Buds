import mysql.connector
import logging
from models.user import UserProfile
import os


class MySQLConnection:
    def __init__(self):
        # 환경 변수에서 MySQL 설정 가져오기
        self.config = {
            "host": os.getenv("MYSQL_HOST", "mysql"),
            "port": int(os.getenv("MYSQL_PORT", "3306")),
            "user": os.getenv("MYSQL_USERNAME", "root"),
            "password": os.getenv("MYSQL_PASSWORD", ""),
            "database": os.getenv("MYSQL_DATABASE", "chatbot_db")
        }
        logging.info(f"MySQL 연결 설정 초기화 완료. 호스트: {self.config['host']}")

    def get_connection(self):
        return mysql.connector.connect(**self.config)

    def get_user_profile(self, user_id):
        """사용자 ID로 프로필 정보를 가져옵니다."""
        try:
            conn = self.get_connection()
            cursor = conn.cursor(dictionary=True)

            # 사용자 기본 정보 가져오기 (seclusion_score를 score로 사용)
            cursor.execute(
                "SELECT user_id, seclusion_score as score FROM users WHERE user_id = %s",
                (user_id,)
            )
            user_data = cursor.fetchone()

            if not user_data:
                return None

            # 사용자 특성 정보 가져오기
            lifestyle_traits = {}
            cursor.execute(
                """
                SELECT openness_score,
                       sociability_score,
                       routine_score,
                       quietness_score,
                       expression_score
                FROM users
                WHERE user_id = %s
                """,
                (user_id,)
            )
            traits_data = cursor.fetchone()

            if traits_data:
                lifestyle_traits = {
                    "openness": traits_data["openness_score"] or 0,
                    "sociability": traits_data["sociability_score"] or 0,
                    "routine": traits_data["routine_score"] or 0,
                    "quietness": traits_data["quietness_score"] or 0,
                    "expression": traits_data["expression_score"] or 0
                }

            # UserProfile 객체 생성
            return UserProfile(
                userId=user_data['user_id'],
                score=user_data['score'],
                lifestyleTraits=lifestyle_traits
            )

        except Exception as e:
            logging.error(f"사용자 프로필 조회 오류: {str(e)}")
            raise
        finally:
            if 'conn' in locals() and conn.is_connected():
                cursor.close()
                conn.close()


# 전역 MySQL 연결 인스턴스
mysql_db = MySQLConnection()