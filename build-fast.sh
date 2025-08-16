#!/bin/bash

echo "Building optimized Glance dashboard..."

# Build the Docker image with optimizations
docker build \
  -t glance-fast \
  --build-arg CGO_ENABLED=0 \
  --build-arg GOOS=linux \
  --build-arg GOARCH=amd64 \
  .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "Run with:"
    echo "  docker run -d -p 8080:8080 -v \$(pwd)/config:/app/config glance-fast"
    echo ""
    echo "Or with your custom config:"
    echo "  docker run -d -p 8080:8080 -v /path/to/your/glance.yml:/app/config/glance.yml glance-fast"
    echo ""
    echo "Access at: http://localhost:8080"
    echo ""
    echo "Performance improvements:"
    echo "  - HTTP timeout reduced from 5s to 2s"
    echo "  - HTTP/2 enabled with connection pooling"
    echo "  - Widget updates run in parallel (max 10 concurrent)"
    echo "  - RSS feeds cached for minimum 5 minutes"
else
    echo "❌ Build failed!"
    exit 1
fi
