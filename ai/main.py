import logging
import uuid
import asyncio
from typing import Dict, Optional
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from pydantic import BaseModel, Field, ValidationError, validator
from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage
import chromadb
from chromadb.utils.embedding_functions import OpenAIEmbeddingFunction
import os
from dotenv import load_dotenv
from typing import Dict

# ---------- [초기화] ----------
# .env 파일에서 OPENAI_API_KEY 불러오기
load_dotenv()
logging.basicConfig(level=logging.INFO)

# FastAPI  인스턴스 생성
app = FastAPI()

# ---------- [ChromaDB 설정] ----------
chroma_client = chromadb.PersistentClient(path="./chroma_data")
embedder = OpenAIEmbeddingFunction(api_key=os.getenv("OPENAI_API_KEY"))

# ---------- [OpenAI 설정] ----------
# OpenAI 챗봇 엔진 초기화(LangChain 표준)
chat = ChatOpenAI(
    model = "gpt-4o",
    temperature = 0.1, # 답변의 창의성 정도(0~1)
    openai_api_key = os.getenv("OPENAI_API_KEY") # 환경변수에서 API키 읽기
)

# ---------- [사용자 프로필 데이터 모델] ----------
class UserProfile(BaseModel):
    userId: int
    score: int
    lifestyleTraits: Dict[str, int]

# ---------- [시스템 프롬프트 생성 함수] ----------
def generate_system_prompt(user_profile: UserProfile, context: Optional[str] = None) -> str:
    traits = user_profile.lifestyleTraits
    user_id = user_profile.userId
    score = user_profile.score

    # 위험도 해석
    if score <= 15:
        risk = "사회적 고립 경향이 낮음"
    elif score <= 24:
        risk = "다소 은둔 성향"
    elif score <= 30:
        risk = "은둔 경향 높음"
    else:
        risk = "심각한 은둔 위험군"

    # 활동 성향 해석
    trait_desc = []
    if traits.get("openness", 0) >= 4:
        trait_desc.append("새로운 장소 탐험을 좋아함")
    if traits.get("sociability", 0) >= 4:
        trait_desc.append("사람들과 어울리는 걸 좋아함")
    if traits.get("routine", 0) >= 4:
        trait_desc.append("규칙적인 생활을 선호함")
    if traits.get("quietness", 0) >= 4:
        trait_desc.append("조용한 환경을 선호함")
    if traits.get("expression", 0) >= 4:
        trait_desc.append("감정/생각 표현을 좋아함")

    trait_text = ", ".join(trait_desc) if trait_desc else "특별한 활동 성향 없음"

    prompt = f"""
너는 {user_id}의 20년 지기 친구야. 반드시 반말로만 답장해.  존댓말, '-시-', '-요', '-습니다' 같은 표현은 절대 사용하지 마.
예시:
- "오늘 기분 어때?"
- "무슨 일이야?"
- "같이 놀러 갈까?"
- "짜증나네. 무슨 일인데?"
{user_id}님은 {score}/40점({risk})이야.
활동 성향: {trait_text}

- 은둔 점수와 성향을 참고해서 대답해.
- 친구처럼 공감과 지지를 많이 표현해.
- 5~7번째 메시지마다 자연스럽게 활동을 추천해줘.
- 추천은 {trait_text}{risk}에 맞는 걸로 해줘.
- 너무 강요하지 말고, "이런 것도 해보면 어때?"처럼 부드럽게 제안해.
"""
    if context:
        prompt += f"\n최근 대화 맥락: {context}\n"
    return prompt

# ---------- [연결 관리 클래스] ----------
class ConnectionManager:
    def __init__(self):
        self.active_connections = {}
        self.lock = asyncio.Lock()

    async def connect(self, user_id: str, websocket: WebSocket):
        async with self.lock:
            self.active_connections[user_id] = websocket

    async def disconnect(self, user_id: str):
        async with self.lock:
            self.active_connections.pop(user_id, None)

manager = ConnectionManager()

# ---------- [데이터 모델] ----------
# 클라이언트에서 받을 메시지의 데이터 구조 정의(1자~500자 유효성 검사)
class MessageRequest(BaseModel):
    user_id: int
    message: str = Field(..., min_length=1, max_length=500)
    # TODO: 이상값 방지 유효성 검사 추가(대량 공백, 특수문자 등)
    @validator('message')
    def check_message(cls, v):
        stripped = v.strip()
        if not stripped:
            raise ValueError("공백만 입력되었습니다")
        if len(stripped) < 2:
            raise ValueError("2자 이상 입력 필요")
        return stripped

# ---------- [HTTP 엔드포인트] ----------
# HTTP POST 방식 챗봇에게 메시지를 보내는 엔드포인트
@app.post("/api/ask")
async def ask(message_request: MessageRequest):
    '''
    사용자 메시지 처리 절차
    1. 사용자별 chromaDB 컬렉션 접근
    2. 현재 메시지와 유사한 과거 대화 3개 검색
    3. 개인화 프롬프트 + 맥락 결합 LLM 응답 생성
    4. 대화 기록 벡터 DB에 저장
    '''
    try:
        # 1. 사용자별 chromaDB 컬렉션 가져오기(없다면 생성)
        collection = chroma_client.get_or_create_collection(
            name=f"user_{message_request.user_id}",  # 시용자 ID 기반 분리
            embedding_function = embedder
        )

        # 2. 현재 메시지와 유사한 과거 대화 최대 3개 맥락 검색
        context = collection.query(
            query_texts = [message_request.message],
            n_results = 3
        )

        # 3. 개인화 프롬프트(실제 서비스에선 DB로부터 사용자 프로필 조회)
        user_profile = UserProfile(
            userId=message_request.user_id,
            score=22,  # 실제로는 DB에서 조회
            lifestyleTraits={
                "openness": 4,
                "sociability": 2,
                "routine": 5,
                "quietness": 4,
                "expression": 3
            }
        )
        system_prompt = generate_system_prompt(user_profile, context)

        # 4. LangChain의 ainvoke로 메시지 전송(HumanMessage 클래스로 역할 구분 전달)
        user_message = message_request.message
        print(f"[사용자] {user_message}")

        response = await chat.ainvoke([
            SystemMessage(content=system_prompt),
            HumanMessage(content=f"Context: {context}\nUser: {message_request.message}")
        ])

        # 5. 대화 기록 저장 (사용자 메시지 + AI 응답)
        collection.add(
            documents=[message_request.message, response.content],
            metadatas=[
                {"type": "user"},
                {"type": "ai"}],
            # 고유 id로 중복 방지
            ids=[uuid.uuid4() for _ in range(2)],
        )
        return {"reply": response.content}

    except ValidationError as e:
        raise HTTPException(status_code=422, detail=str(e))
    except Exception as e:
        logging.error(f"Error: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail="서버 내부 오류")

# ---------- [WebSocket 엔드포인트] ----------
@app.websocket("/ws/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: int):
    '''
    실시간 채팅 처리 절차
    1. websocket 연결 수락
    2. 사용자별 chromaDB 컬렉션 준비
    3. 클라이언트 메시지 수신 -> 처리 -> 응답 전송
    4. 예외 처리 및 연결 정리
    '''
    await websocket.accept() # 클라이언트 연결 수락

    user_profile = UserProfile(
        userId=user_id,
        score=22,  # 예시 값
        lifestyleTraits={
            "openness": 4,
            "sociability": 2,
            "routine": 5,
            "quietness": 4,
            "expression": 3
        }
    )
    await manager.connect(str(user_id), websocket)

    # 1. 사용자별 chromaDB 컬렉션 준비
    collection = chroma_client.get_or_create_collection(
        name = f"user_{user_id}",
        embedding_function = embedder
    )

    # 마멋이 먼저 인사말을 보내는 경우
    system_prompt = generate_system_prompt(user_profile)
    # TODO: 사용자 개인화 메시지로 변경
    ai_reply = await chat.ainvoke([
        SystemMessage(content=system_prompt),
        HumanMessage(content="친구에게 먼저 인사해줘")])
    await websocket.send_json({
        "from": "ai",
        "message": ai_reply.content
    })

    # 연결 상태 모니터링 태스크
    async def heartbeat():
        while True:
            await asyncio.sleep(30)
            try:
                await websocket.send_json({"type": "heartbeat"})
            except:
                break

    heartbeat_task = asyncio.create_task(heartbeat())

    # 2. 클라이언트로부터 JSON 데이터 수신
    try:
        msg_counter = 0
        while True:
            data = await websocket.receive_json()
            user_message = data.get("content")

            #3. 메시지 유효성 검사
            if not user_message:
                await websocket.send_json({"error": "메시지 필수"})

                continue
            msg_counter += 1
            #4. 맥락 검색(과거 유사 대화 3개)
            context = collection.query(
                query_texts=[user_message],
                n_results = 3,
                where={"type": "user"}
            )

            # 7. 활동 추천 시점 확인
            if msg_counter % 6 == 0:
                current_prompt = system_prompt + "\n[중요] 활동을 추천해주세요!"
            else:
                current_prompt = system_prompt

            #5. LLM 응답 생성(시스템 프롬프트 + 맥락 + 메시지)
            response = await chat.ainvoke([
                SystemMessage(content=current_prompt),
                # TODO: 동적 생성 필요
                HumanMessage(content=f"Context:{context}\nUser:{user_message}")
            ])

            #6. 대화 기록 저장
            collection.add(
                documents=[user_message, response.content],
                metadatas=[{"type": "user"}, {"type": "ai"}],
                ids=[str(uuid.uuid4()), str(uuid.uuid4())]
                #UUID로 고유성 보장
            )
            #7. 응답 전송
            await websocket.send_json({
                "from": "ai",
                "message": response.content
            })

    except WebSocketDisconnect:
        logging.info(f"{user_id} 연결 종료")
    except ValidationError:
        await websocket.send_json({"error": "잘못된 요청 형식"})
    except Exception as e:
        logging.error(str(e))
        await websocket.send_json({"error": "내부 서버 오류"})
    finally:
        await websocket.close()

# ---------- [기본 엔드포인트] ----------
# 서버 확인용 기본 루트 엔드포인트
@app.get("/")
def read_root():
    return {"status": "active", "connections": len(manager.active_connections)}

# ---------- [실행 설정] ----------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)