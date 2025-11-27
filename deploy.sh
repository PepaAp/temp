#!/bin/bash

# 🐋 Deployment script pro Flask-OS
# Tento script buildí a publikuje Docker images na GitHub Container Registry

set -e  # Exit on error

REGISTRY="ghcr.io"
USERNAME="petrgru"
REPO="flask-os"
VERSION="${1:-latest}"

echo "🚀 Starting deployment for ${REGISTRY}/${USERNAME}/${REPO}:${VERSION}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if logged in to GHCR
echo -e "${BLUE}🔐 Checking Docker login...${NC}"
if ! docker info | grep -q "Username"; then
    echo -e "${YELLOW}⚠️  Not logged in to Docker registry${NC}"
    echo "Please login first:"
    echo "  export CR_PAT=YOUR_GITHUB_TOKEN"
    echo "  echo \$CR_PAT | docker login ghcr.io -u ${USERNAME} --password-stdin"
    exit 1
fi

# Build Flask application image
echo -e "${BLUE}🔨 Building Flask application image...${NC}"
docker build -f Dockerfile-flask \
    -t ${REGISTRY}/${USERNAME}/${REPO}:${VERSION} \
    -t ${REGISTRY}/${USERNAME}/${REPO}:latest \
    .
echo -e "${GREEN}✅ Flask image built successfully${NC}"

# Build Nginx image
echo -e "${BLUE}🔨 Building Nginx image...${NC}"
docker build -f Dockerfile-nginx \
    -t ${REGISTRY}/${USERNAME}/${REPO}-nginx:${VERSION} \
    -t ${REGISTRY}/${USERNAME}/${REPO}-nginx:latest \
    .
echo -e "${GREEN}✅ Nginx image built successfully${NC}"

# Push images
echo -e "${BLUE}📤 Pushing images to registry...${NC}"

echo "Pushing Flask image..."
docker push ${REGISTRY}/${USERNAME}/${REPO}:${VERSION}
docker push ${REGISTRY}/${USERNAME}/${REPO}:latest

echo "Pushing Nginx image..."
docker push ${REGISTRY}/${USERNAME}/${REPO}-nginx:${VERSION}
docker push ${REGISTRY}/${USERNAME}/${REPO}-nginx:latest

echo -e "${GREEN}✅ All images pushed successfully!${NC}"

# Display summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo "Published images:"
echo "  📦 ${REGISTRY}/${USERNAME}/${REPO}:${VERSION}"
echo "  📦 ${REGISTRY}/${USERNAME}/${REPO}:latest"
echo "  📦 ${REGISTRY}/${USERNAME}/${REPO}-nginx:${VERSION}"
echo "  📦 ${REGISTRY}/${USERNAME}/${REPO}-nginx:latest"
echo ""
echo "To use these images:"
echo "  docker pull ${REGISTRY}/${USERNAME}/${REPO}:latest"
echo "  docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo "To make packages public:"
echo "  1. Visit: https://github.com/${USERNAME}?tab=packages"
echo "  2. Select your package"
echo "  3. Package settings → Change visibility → Public"
echo ""
