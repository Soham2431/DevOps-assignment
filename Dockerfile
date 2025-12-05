# ---------- Builder Stage ----------
FROM python:3.11-slim AS builder

WORKDIR /app

# System deps (optional, kept minimal)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install -r requirements.txt

COPY app ./app

# ---------- Runtime Stage ----------
FROM python:3.11-slim

# Create non-root user
RUN useradd -u 10001 -m appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local
COPY app ./app

ENV PYTHONUNBUFFERED=1
ENV PREDICT_SCORE=0.75

EXPOSE 8000

# Healthcheck for container runtime
HEALTHCHECK --interval=30s --timeout=5s --retries=3 CMD \
  python -c "import requests; \
  import os; \
  import sys; \
  url='http://127.0.0.1:8000/health'; \
  import requests; \
  sys.exit(0 if requests.get(url).status_code == 200 else 1)" || exit 1

USER appuser

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
