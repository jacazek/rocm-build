#!/usr/bin/env bash
# consider making separate venv for webui
# source .venv/bin/activate
ls
cd thirdy_party/open-webui
# npm ci
# npm run build

# cd backend
# pip install -r requirements.txt





export ENABLE_IMAGE_GENERATION="true"
export IMAGE_SIZE="512x512" 
export ENABLE_OLLAMA_API="false" 
export WEB_AUTH="False" 
export OPENAI_API_BASE_URL="http://localhost:8000/v1" 
export PORT="8001" 
export ROCR_VISIBLE_DEVICES=0
# export HSA_OVERRIDE_GFX_VERSION=11.0.0
export HSA_ENABLE_SDMA=0
export USE_CUDA_DOCKER=true
export HOST="0.0.0.0"

./backend/start.sh
