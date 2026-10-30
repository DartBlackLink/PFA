FROM python:3.12-slim
WORKDIR /workspace
COPY backend/requirements*.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.lock.txt -r /tmp/requirements-dev.txt
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=/workspace/backend
