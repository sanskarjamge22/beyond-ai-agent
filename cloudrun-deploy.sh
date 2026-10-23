#!/usr/bin/env bash
# FoodBridge AI — Google Cloud Run Deployment Script
set -e

PROJECT_ID=${GOOGLE_CLOUD_PROJECT:-"foodbridge-ai-hackathon"}
SERVICE_NAME="foodbridge-ai"
REGION="us-central1"
IMAGE_TAG="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:latest"

echo "=========================================================="
echo " Deploying FoodBridge AI to Google Cloud Run"
echo " Project: ${PROJECT_ID} | Region: ${REGION}"
echo "=========================================================="

# Build container via Google Cloud Build
echo "[1/3] Building container image with Google Cloud Build..."
gcloud builds submit --project="${PROJECT_ID}" --tag="${IMAGE_TAG}" .

# Deploy container to Google Cloud Run
echo "[2/3] Deploying service to Google Cloud Run..."
gcloud run deploy "${SERVICE_NAME}" \
  --project="${PROJECT_ID}" \
  --image="${IMAGE_TAG}" \
  --region="${REGION}" \
  --platform="managed" \
  --allow-unauthenticated \
  --set-env-vars="APP_ENV=production,DEMO_MODE=true" \
  --memory="1Gi" \
  --cpu="1" \
  --min-instances="0" \
  --max-instances="5" \
  --timeout="300"

echo "[3/3] Deployment complete! Retrieve service URL with:"
gcloud run services describe "${SERVICE_NAME}" --project="${PROJECT_ID}" --region="${REGION}" --format="value(status.url)"
