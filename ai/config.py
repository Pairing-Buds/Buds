import os
import logging
import openai  # openai 패키지 임포트 추가
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

# 상위 디렉토리의 .env 파일 로드
load_dotenv(dotenv_path='../.env')

class Settings(BaseSettings):
    OPENAI_API_KEY: str = os.getenv("OPENAI_API_KEY", "")

    class Config:
        env_file = ".env"

settings = Settings()

# OpenAI API 키 설정
openai.api_key = settings.OPENAI_API_KEY

if not settings.OPENAI_API_KEY:
    logging.warning("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")

# MySQL 설정
MYSQL_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "port": int(os.getenv("MYSQL_PORT", "3306")),
    "user": os.getenv("MYSQL_USER", "root"),
    "password": os.getenv("MYSQL_PASSWORD", ""),
    "database": os.getenv("MYSQL_DATABASE", "chatbot_db")
}

# ChromaDB 설정
CHROMA_DATA_PATH = "./chroma_data"

# 로깅 설정
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")