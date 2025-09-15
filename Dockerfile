# Dockerfile
# Stage 1: Go builder
FROM golang:1.22-alpine AS go-builder

WORKDIR /app

COPY go.* ./

RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /go-proxy ./main.go

# Stage 2: PocketBase downloader
FROM alpine:latest AS pb-downloader

ARG PB_VERSION=0.30.0

WORKDIR /app

RUN apk add curl unzip
RUN curl -L "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip" -o pb.zip && \
    unzip pb.zip && \
    rm pb.zip

# Stage 3: Final image
FROM alpine:latest

COPY --from=go-builder /go-proxy /usr/local/bin/

COPY --from=pb-downloader /app/pocketbase /usr/local/bin/

RUN mkdir -p /pb_data

VOLUME /pb_data

EXPOSE 8080

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]