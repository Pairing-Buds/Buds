from typing import Optional
from fastapi import Cookie, HTTPException, status
import jwt
from jwt.exceptions import ExpiredSignatureError, InvalidTokenError
import logging
import os

# Spring과 동일한 JWT 설정
JWT_SECRET_KEY = os.getenv("JWT_SECRET")
ALGORITHM = "HS256"

logger = logging.getLogger(__name__)


def get_user_id_from_token(
        access_token: Optional[str] = Cookie(None)
) -> Optional[int]:
    """
    쿠키에서 JWT 토큰을 추출하고 사용자 ID를 반환합니다.
    사용자 ID가 없거나 토큰이 유효하지 않은 경우 예외를 발생시킵니다.
    """
    if not access_token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증이 필요합니다"
        )

    try:
        # JWT 토큰 디코딩
        payload = jwt.decode(access_token, JWT_SECRET_KEY, algorithms=[ALGORITHM])

        # Spring의 JwtTokenProvider에서 사용하는 claim 이름이 "userId"이므로 동일하게 사용
        user_id = payload.get("userId")

        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="유효하지 않은 인증 정보"
            )

        return user_id

    except ExpiredSignatureError:
        logger.warning("만료된 JWT 토큰")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="인증 토큰이 만료되었습니다"
        )
    except InvalidTokenError as e:
        logger.warning(f"유효하지 않은 JWT 토큰: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="유효하지 않은 인증 토큰"
        )
    except Exception as e:
        logger.error(f"JWT 토큰 처리 중 오류 발생: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="서버 내부 오류"
        )