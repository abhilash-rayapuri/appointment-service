FROM python:3.13-slim

# ---- Security hardening ----
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# Prevent root usage
RUN useradd -m appuser

WORKDIR /app

# ---- Install system security updates ----
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---- Install dependencies first (better caching) ----
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ---- Copy source code ----
COPY src ./src

# ---- Ownership + security ----
RUN chown -R appuser:appuser /app

USER appuser

# ---- Expose port ----
EXPOSE 8002

# ---- Run app securely ----
CMD ["uvicorn", "src.appointment_service.main:app", "--host", "0.0.0.0", "--port", "8002"]
