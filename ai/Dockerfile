FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc build-essential default-libmysqlclient-dev pkg-config ffmpeg git && \
    pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir pydantic-settings && \
    apt-get purge -y --auto-remove gcc build-essential && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PyAnimalese 저장소 클론
RUN git clone https://github.com/hwi-middle/PyAnimalese.git && \
    cd PyAnimalese && \
    pip install -r requirements.txt

# 소스 코드 복사
COPY . .

# chroma_data 디렉토리 생성
RUN mkdir -p ./chroma_data && \
    chmod -R 777 ./chroma_data

EXPOSE 8000

# 상태 확인 추가
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]