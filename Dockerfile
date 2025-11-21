FROM python:3.11-slim
WORKDIR /app

# 간단한 테스트용 Flask 애플리케이션을 위한 Dockerfile
# (빌드 컨텍스트에 requirements.txt/other files가 필요하지 않음)
COPY . /app
RUN pip install --no-cache-dir flask
ENV FLASK_ENV=production
EXPOSE 8000
CMD ["python", "-c", "from flask import Flask\napp = Flask(__name__)\n\n@app.route(\"/\")\ndef h():\n    return \"ok\"\n\nif __name__ == \"__main__\":\n    app.run(host=\"0.0.0.0\", port=8000)"]