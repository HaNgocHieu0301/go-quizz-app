#!/bin/bash

# Kill any existing processes on these ports
pkill -f "pocketbase serve"
pkill -f "go run main.go"

# Wait a moment for processes to terminate
sleep 2

echo "Starting PocketBase server..."
./pocketbase serve --http=127.0.0.1:8090 &
POCKETBASE_PID=$!

# Wait for PocketBase to start
sleep 3

echo "Starting Go proxy server with auto-reload..."
~/go/bin/air &
GO_PID=$!

echo "Both servers are running:"
echo "PocketBase: http://127.0.0.1:8090"
echo "Go Proxy: http://127.0.0.1:8081"
echo ""
echo "Press Ctrl+C to stop both servers"

# Function to cleanup when script is terminated
cleanup() {
    echo ""
    echo "Stopping servers..."
    kill $POCKETBASE_PID 2>/dev/null
    kill $GO_PID 2>/dev/null
    wait $POCKETBASE_PID 2>/dev/null
    wait $GO_PID 2>/dev/null
    echo "Servers stopped."
    exit 0
}

# Set trap to cleanup on script termination
trap cleanup SIGINT SIGTERM

# Wait for both processes
wait