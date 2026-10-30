FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
WORKDIR /app
COPY requirements.txt requirements.lock.txt ./
RUN pip install --no-cache-dir -r requirements.lock.txt \
    && groupadd --system app && useradd --system --gid app --home-dir /app app
COPY --chown=app:app app ./app
COPY --chown=app:app alembic.ini .
COPY --chown=app:app migrations ./migrations
USER app
EXPOSE 8000
CMD ["sh", "-c", "alembic upgrade head && exec uvicorn app.main:app --host 0.0.0.0 --port 8000"]
