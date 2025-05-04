from pydantic import BaseModel, Field, validator

class MessageRequest(BaseModel):
    user_id: int
    message: str = Field(..., min_length=1, max_length=500)

    @validator('message')
    def check_message(cls, v):
        stripped = v.strip()
        if not stripped:
            raise ValueError("공백만 입력되었습니다")
        if len(stripped) < 2:
            raise ValueError("2자 이상 입력 필요")
        return stripped


class MessageResponse(BaseModel):
    reply: str