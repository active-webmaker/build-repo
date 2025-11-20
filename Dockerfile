FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir flask
ENV FLASK_ENV=production
EXPOSE 8000
CMD ["python", "-c", "from flask import Flask; app=Flask(__name__); @app.route('/')\ndef h(): return 'ok'; app.run(host='0.0.0.0', port=8000)"]
# Python 이미지를 기반으로 설정
FROM python:3.9-slim

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사
COPY requirements.txt .

# 의존성 설치
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드 복사
COPY src/ .

# 애플리케이션 실행
CMD ["python", "main.py"]