#!/bin/bash

# Test script for Valhalla Docker Compose setup

echo "🚀 Testing Valhalla Docker Compose Setup"
echo "========================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

echo "✅ Docker is running"

# Create data directories if they don't exist
mkdir -p data gtfs_feeds
echo "✅ Data directories created"

# Test the main configuration (using pre-built image)
echo ""
echo "📋 Testing main configuration (pre-built image)..."
docker compose -f docker-compose.yaml config > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Main configuration is valid"
else
    echo "❌ Main configuration has errors"
    exit 1
fi

# Test the override configuration (build from source)
echo ""
echo "📋 Testing override configuration (build from source)..."
docker compose -f docker-compose.yaml -f docker-compose.override.yaml config > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Override configuration is valid"
else
    echo "❌ Override configuration has errors"
    exit 1
fi

echo ""
echo "🎉 All configurations are valid!"
echo ""
echo "To start Valhalla with pre-built image:"
echo "  docker compose up -d"
echo ""
echo "To build from source:"
echo "  docker compose -f docker-compose.yaml -f docker-compose.override.yaml up --build"
echo ""
echo "To check service status:"
echo "  docker compose ps"
echo "  curl http://localhost:8002/status"
