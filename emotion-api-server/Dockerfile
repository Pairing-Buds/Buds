FROM nvidia/cuda:12.1.1-base-ubuntu22.04

WORKDIR /app

RUN apt-get update && \
    apt-get install -y python3.10 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "1"]
