#!/bin/sh

# Run PocketBase in the background
# Data will be stored in /pb_data directory
# It will run on port 8090 inside the container
pocketbase serve --http="0.0.0.0:8090" &

# Run Go Proxy in the foreground
# It will receive the PORT environment variable from Fly.io (default is 8080)
exec /usr/local/bin/go-proxy