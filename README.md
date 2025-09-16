# Go Quiz App

A Go-based quiz application that uses PocketBase as the backend database and includes a proxy server built with Fiber.

## Architecture

This application consists of two main components:
- **PocketBase**: Backend database server running on port 8090
- **Go Proxy**: Fiber-based proxy server running on port 8081 that forwards API requests to PocketBase

## Prerequisites

- Go 1.22.2 or higher
- Docker (optional, for containerized deployment)

## Local Development

### Running Locally

1. **Clone the repository**
   ```bash
   git clone https://github.com/HaNgocHieu0301/go-quizz-app.git
   cd go-quizz-app
   ```

2. **Install dependencies**
   ```bash
   go mod download
   ```

3. **Set up PocketBase**
   - Download PocketBase binary for your platform from [PocketBase releases](https://github.com/pocketbase/pocketbase/releases)
   - Place the binary in the project root or add it to your PATH
   - Create a data directory:
     ```bash
     mkdir pb_data
     ```

4. **Start PocketBase**
   ```bash
   ./pocketbase serve --http="127.0.0.1:8090"
   ```
   
   PocketBase admin UI will be available at: http://127.0.0.1:8090/_/

5. **Set environment variable and run the Go proxy**
   ```bash
   export POCKETBASE_URL="http://127.0.0.1:8090"
   go run main.go
   ```

6. **Access the application**
   - Proxy server: http://localhost:8081
   - API endpoints: http://localhost:8081/api/*
   - PocketBase admin: http://127.0.0.1:8090/_/

### Environment Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `POCKETBASE_URL` | URL of the PocketBase server | - | Yes |

## Docker Deployment

### Using Docker Compose (Recommended)

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  quiz-app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - POCKETBASE_URL=http://localhost:8090
    volumes:
      - pb_data:/pb_data

volumes:
  pb_data:
```

Run with Docker Compose:
```bash
docker-compose up -d
```

### Using Docker directly

1. **Build the Docker image**
   ```bash
   docker build -t go-quiz-app .
   ```

2. **Run the container**
   ```bash
   docker run -d \
     --name quiz-app \
     -p 8080:8080 \
     -e POCKETBASE_URL="http://localhost:8090" \
     -v quiz_data:/pb_data \
     go-quiz-app
   ```

3. **Access the application**
   - Application: http://localhost:8080
   - API endpoints: http://localhost:8080/api/*

## Project Structure

```
go-quizz-app/
├── main.go           # Go proxy server with Fiber
├── go.mod            # Go module dependencies
├── go.sum            # Go module checksums
├── Dockerfile        # Multi-stage Docker build
├── entrypoint.sh     # Docker entrypoint script
├── fly.toml          # Fly.io deployment configuration
├── pocketbase/       # PocketBase directory (if present)
├── pb_data/          # PocketBase data directory
└── README.md         # This file
```

## API Usage

All API requests should be made to `/api/*` endpoints, which will be proxied to the PocketBase server.

Example API calls:
```bash
# Get collections
curl http://localhost:8081/api/collections

# Authentication
curl -X POST http://localhost:8081/api/collections/users/auth-with-password \
  -H "Content-Type: application/json" \
  -d '{"identity":"user@example.com","password":"password"}'
```

## Database Schema Management

To ensure consistent PocketBase database schema and tables across different machines, follow these approaches:

### Method 1: Export/Import Schema (Recommended)

1. **Export current schema from existing setup:**
   ```bash
   ./pocketbase admin export-collections > schema.json
   ```

2. **Import schema on new machine:**
   ```bash
   ./pocketbase admin import-collections schema.json
   ```

3. **Add schema to version control:**
   ```bash
   git add schema.json
   git commit -m "Add database schema"
   ```

### Method 2: Setup Script

Create an automated setup script:

```bash
#!/bin/bash
# setup.sh
echo "Setting up PocketBase database..."

# Create data directory if it doesn't exist
mkdir -p pb_data

# Import schema if schema.json exists
if [ -f "schema.json" ]; then
    echo "Importing database schema..."
    ./pocketbase admin import-collections schema.json
    echo "Schema imported successfully!"
else
    echo "No schema.json found. Please export schema from existing setup."
fi

echo "Database setup complete!"
```

Make it executable:
```bash
chmod +x setup.sh
```

### Method 3: Database Backup/Restore

For complete data consistency (including records):

```bash
# Create backup
./pocketbase admin create-backup

# Restore backup on new machine
./pocketbase admin restore-backup backup_file.zip
```

### Updated Setup Instructions

**For first-time setup:**
1. Follow the "Running Locally" steps above
2. Configure your database schema in PocketBase admin
3. Export schema: `./pocketbase admin export-collections > schema.json`
4. Commit schema to version control

**For team members setting up:**
1. Clone the repository
2. Run setup script: `./setup.sh` (if available)
3. Or manually import: `./pocketbase admin import-collections schema.json`
4. Start PocketBase and the Go proxy

## Development Tips

1. **PocketBase Admin**: Access the PocketBase admin interface to manage your database schema, view data, and configure authentication.

2. **Logs**: The Go proxy includes request logging middleware for debugging.

3. **CORS**: Configure CORS settings in PocketBase admin if you need to make requests from a web frontend.

4. **Schema Changes**: Always export and commit schema changes to keep team members in sync.

## Troubleshooting

### Common Issues

1. **"POCKETBASE_URL environment variable is not set"**
   - Make sure to set the `POCKETBASE_URL` environment variable before running the Go application

2. **Connection refused errors**
   - Ensure PocketBase is running and accessible at the specified URL
   - Check that no firewall is blocking the connections

3. **Port already in use**
   - Make sure ports 8080, 8081, and 8090 are not being used by other applications
   - You can change the ports in the configuration if needed

### Logs

- Go proxy logs: Check the console output where you ran `go run main.go`
- PocketBase logs: Check the console output where you ran PocketBase
- Docker logs: `docker logs <container-name>`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## License