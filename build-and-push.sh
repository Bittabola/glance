#!/bin/bash

set -e

REGISTRY="ghcr.io"
USERNAME="bittabola"
IMAGE_NAME="glance"
TAG="latest"
FULL_IMAGE_NAME="${REGISTRY}/${USERNAME}/${IMAGE_NAME}:${TAG}"

echo "🚀 Building and pushing optimized Glance to GHCR..."
echo "Target: ${FULL_IMAGE_NAME}"
echo ""

# Check if logged in to GHCR by attempting to access a registry
echo "🔐 Using existing GHCR authentication..."
echo "ℹ️  If build fails with auth error, please run: docker login ghcr.io"

# Build multi-architecture image for AMD64
echo "🏗️  Building AMD64 image with buildx..."
docker buildx create --use --name glance-builder || docker buildx use glance-builder

docker buildx build \
    --platform linux/amd64 \
    --tag ${FULL_IMAGE_NAME} \
    --tag ${REGISTRY}/${USERNAME}/${IMAGE_NAME}:fast \
    --push \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully built and pushed to GHCR!"
    echo ""
    echo "📦 Image available at:"
    echo "   ${FULL_IMAGE_NAME}"
    echo "   ${REGISTRY}/${USERNAME}/${IMAGE_NAME}:fast"
    echo ""
    echo "🏃 To run from GHCR:"
    echo "   docker run -d -p 8080:8080 -v \$(pwd)/config:/app/config ${FULL_IMAGE_NAME}"
    echo ""
    echo "🔧 Features included:"
    echo "   • HTTP timeout: 2s (reduced from 5s)"
    echo "   • HTTP/2 + connection pooling enabled"
    echo "   • Parallel widget loading (max 10 concurrent)"
    echo "   • RSS feed caching (5min minimum)"
    echo "   • Platform: linux/amd64"
else
    echo "❌ Build or push failed!"
    exit 1
fi
