# =========
# Builder
# =========
FROM python:3.11-slim AS builder

WORKDIR /app

# Install system deps (for building wheels)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY app/requirements.txt .

RUN pip install --upgrade pip \
    && pip install --prefix=/install -r requirements.txt

# =========
# Runtime
# =========
FROM python:3.11-slim

# Create non-root user
RUN useradd -m -u 10001 appuser

WORKDIR /app

# Copy installed packages from builder
COPY --from=builder /install /usr/local

# Copy source
COPY app /app

# Install curl only for healthcheck
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Security best practices
USER appuser

ENV PORT=8000

EXPOSE 8000

# Docker HEALTHCHECK (container-level)
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
