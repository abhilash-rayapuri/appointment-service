FROM python:3.13-slim

# ---- Security hardening ----
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# ---- Create non-root user ----
RUN useradd -m appuser

WORKDIR /app

# ---- System security updates (reduce CVEs slightly) ----
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*

# ---- Dependencies layer (cached) ----
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ---- Copy source code ----
COPY src ./src

# ---- Fix permissions ----
RUN chown -R appuser:appuser /app

USER appuser

# ---- Security: explicit port ----
EXPOSE 8002

# ---- Runtime ----
CMD ["uvicorn", "src.appointment_service.main:app", "--host", "0.0.0.0", "--port", "8002"]
