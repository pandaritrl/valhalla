#!/bin/bash

# Quick start script for Valhalla Docker Compose

set -e

echo "🚀 Starting Valhalla Docker Compose Setup"
echo "========================================="

# Parse command line arguments
BUILD_FROM_SOURCE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            BUILD_FROM_SOURCE=true
            shift
            ;;
        --quiet|-q)
            QUIET=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --build    Build from source instead of using pre-built image"
            echo "  --quiet    Suppress output"
            echo "  --help     Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Start with pre-built image"
            echo "  $0 --build           # Build from source"
            echo "  $0 --build --quiet   # Build from source quietly"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Create data directories
mkdir -p data gtfs_feeds

if [ "$QUIET" = false ]; then
    echo "✅ Data directories created"
fi

# Start the service
if [ "$BUILD_FROM_SOURCE" = true ]; then
    if [ "$QUIET" = false ]; then
        echo "🔨 Building Valhalla from source..."
    fi
    docker compose -f docker-compose.yaml -f docker-compose.override.yaml up --build -d
else
    if [ "$QUIET" = false ]; then
        echo "📦 Starting Valhalla with pre-built image..."
    fi
    docker compose up -d
fi

# Wait a moment for the service to start
sleep 5

# Check if the service is running
if docker compose ps | grep -q "Up"; then
    if [ "$QUIET" = false ]; then
        echo "✅ Valhalla service is running!"
        echo ""
        echo "🌐 Service endpoints:"
        echo "  - Valhalla API: http://localhost:8002"
        echo "  - Health check: http://localhost:8002/status"
        echo ""
        echo "📊 Management commands:"
        echo "  - View logs: docker compose logs -f"
        echo "  - Stop service: docker compose down"
        echo "  - Restart service: docker compose restart"
        echo ""
        echo "🧪 Test the service:"
        echo "  curl http://localhost:8002/status"
    fi
else
    echo "❌ Failed to start Valhalla service"
    echo "Check logs with: docker compose logs"
    exit 1
fi
