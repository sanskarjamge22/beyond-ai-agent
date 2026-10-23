# Stage 1: Build Frontend React Bundle
FROM node:20-slim AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# Stage 2: Production Python Backend & Runtime
FROM python:3.11-slim
WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PORT=8000 \
    APP_ENV=production

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy backend requirements and install
COPY backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application
COPY backend/app ./app

# Copy built frontend bundle from Stage 1 into location expected by app.main
COPY --from=frontend-builder /app/frontend/dist /frontend/dist

EXPOSE 8000

# Start Uvicorn server for Google Cloud Run
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
