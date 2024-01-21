# Dockerfile
FROM python:3.6

WORKDIR /app

COPY . /app

RUN pip install flask redis

CMD ["python3", "greet.py"]
