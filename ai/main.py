from fastapi import FastAPI, WebSocket
from pydantic import BaseModel, Field
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage
import os
from dotenv import load_dotenv
import json
import asyncio

# .env 파일에서 OPENAI_API_KEY 불러오기
load_dotenv()

# FastAPI  인스턴스 생성
app = FastAPI()

# OpenAI 챗봇 엔진 초기화(LangChain 표준)
chat = ChatOpenAI(
    model = "gpt-4o",
    temperature = 0.8, # 답변의 창의성 정도(0~1)
    openai_api_key = os.getenv("OPENAI_API_KEY") # 환경변수에서 API키 읽기
)

# 클라이언트에서 받을 메시지의 데이터 구조 정의(1자~500자 유효성 검사)
class MessageRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=500)
    # TODO: 이상값 방지 유효성 검사 추가(대량 공백, 특수문자 등)

# HTTP POST 방식 챗봇에게 메시지를 보내는 엔드포인트
@app.post("/api/ask")
async def ask(message_request: MessageRequest):
    user_message = message_request.message
    print(f"[사용자] {user_message}")

#LangChain의 ainvoke로 메시지 전송(HumanMessage 클래스로 역할 구분 전달)
    response = await chat.ainvoke([HumanMessage(content=user_message)])
    print(f"[GPT 응답] {response.content}")
    # 응답 메시지는 .content에 들어있음
    return {"reply": response.content}

# websoket 실시간 양방향 채팅 엔드포인트
@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept() # 클라이언트 연결 수락

# 마멋이 먼저 인사말을 보내는 경우
    greeting_prompt = "오늘 하루 어땠어? 지금 기분은 어때?"
    # TODO: 사용자 개인화 메시지로 변경
    ai_reply = await chat.ainvoke([HumanMessage(content=greeting_prompt)])
    await websocket.send_text(json.dumps({
        "from": "ai",
        "message": ai_reply.content
    }))

# 사용자가 메시지를 보내면 마멋이 답변
    while True:
        try:
            user_message = await websocket.receive_text() # 사용자 메시지 수신
            print(f"[사용자] {user_message}")
            response = await chat.ainvoke([HumanMessage(content=user_message)])
            await websocket.send_text(json.dumps({
                "from": "ai",
                "message": response.content # 챗봇 답변 전송
            }))
        except Exception as e:
            # 에러 발생 시 에러 메시지 전송 후 루프 종료
            await websocket.send_text(json.dumps({"error": str(e)}))
            break

# 서버 확인용 기본 루트 엔드포인트
@app.get("/")
def read_root():
    return {"message": "Hello FastAPI!"}