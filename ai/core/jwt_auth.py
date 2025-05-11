from typing import Optional
from fastapi import Cookie, HTTPException, status, Request
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
import logging
import os
import base64

# Spring과 동일한 JWT 설정
JWT_SECRET_KEY = os.getenv("JWT_SECRET")
ALGORITHM = "HS256"

logger = logging.getLogger(__name__)


def get_user_id_from_token(request: Request) -> Optional[int]:
    # 요청 객체에서 직접 쿠키 접근
    access_token = request.cookies.get("access_token")

    if not access_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증이 필요합니다"
        )

    # 기존 토큰 검증 로직
    try:
        secret_key = os.getenv("JWT_SECRET")
        # Base64 디코딩 (Spring 방식과 일치)
        if secret_key:
            secret_key_bytes = base64.b64decode(secret_key)
        else:
            logger.error("JWT_SECRET 환경 변수가 설정되지 않았습니다!")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="서버 구성 오류"
            )

        # JWT 검증
        payload = jwt.decode(access_token, secret_key_bytes, algorithms=["HS256"])

        # 사용자 ID 반환
        return payload.get("userId")

    except Exception as e:
        logger.error(f"JWT 토큰 처리 중 오류: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="유효하지 않은 인증 토큰"
        )