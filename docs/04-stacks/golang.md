# 🔵 Golang Stack
> Referensi: 02-docker.md untuk Docker | 05-fullstack.md untuk koneksi frontend

Template: 📄 Belum dibuat
Stack: Go 1.22 + Nginx + PostgreSQL 16 + Redis
Port default: 8080

---

## Kenapa Golang?

    Kecepatan    → hampir secepat C, jauh lebih cepat dari PHP/Python
    Concurrency  → goroutines — handle ribuan request bersamaan dengan mudah
    Binary       → compile ke satu file binary — deploy sangat mudah
    Memory       → penggunaan memory sangat efisien
    Cocok untuk  → microservice, API high-performance, tools CLI

---

## Install Go (untuk development lokal)

    brew install go
    go version    # go version go1.22.x darwin/arm64

---

## Buat Template Golang

    GOLANG=~/Developer/tools/templates/backend/golang
    mkdir -p $GOLANG/docker

Buat Dockerfile ($GOLANG/Dockerfile):

    # Stage 1 — Build
    FROM golang:1.22-alpine AS builder
    WORKDIR /app
    COPY go.mod go.sum ./
    RUN go mod download
    COPY . .
    RUN CGO_ENABLED=0 GOOS=linux go build -o main .

    # Stage 2 — Run (image jauh lebih kecil!)
    FROM alpine:latest
    RUN apk --no-cache add ca-certificates
    WORKDIR /app
    COPY --from=builder /app/main .
    EXPOSE 8080
    CMD ["./main"]

Multi-stage build:
- Stage 1 compile kode (image besar ~800MB)
- Stage 2 hanya copy binary hasil compile (image kecil ~20MB)
- Production image jadi sangat ringan!

Buat go.mod ($GOLANG/go.mod):

    module myapp

    go 1.22

    require (
        github.com/gin-gonic/gin v1.9.1
        github.com/lib/pq v1.10.9
        github.com/redis/go-redis/v9 v9.5.1
        github.com/joho/godotenv v1.5.1
        github.com/golang-jwt/jwt/v5 v5.2.1
    )

Buat entry point ($GOLANG/main.go):

    package main

    import (
        "net/http"
        "os"
        "github.com/gin-gonic/gin"
        "github.com/joho/godotenv"
    )

    func main() {
        godotenv.Load()

        r := gin.Default()

        r.GET("/", func(c *gin.Context) {
            c.JSON(http.StatusOK, gin.H{
                "message": "Golang API running!",
                "status":  "ok",
            })
        })

        r.GET("/api/health", func(c *gin.Context) {
            c.JSON(http.StatusOK, gin.H{"status": "healthy"})
        })

        port := os.Getenv("PORT")
        if port == "" {
            port = "8080"
        }
        r.Run(":" + port)
    }

Buat docker-compose.yml ($GOLANG/docker-compose.yml):

    services:
      app:
        build: .
        container_name: ${APP_NAME}-golang
        restart: unless-stopped
        ports:
          - "${APP_PORT:-8080}:8080"
        environment:
          - PORT=8080
          - DATABASE_URL=postgres://${DB_USERNAME}:${DB_PASSWORD}@db:5432/${DB_DATABASE}
          - REDIS_URL=redis://redis:6379/0
        depends_on:
          db:
            condition: service_healthy
        networks:
          - app-network

      db:
        image: postgres:16-alpine
        container_name: ${APP_NAME}-postgres
        environment:
          POSTGRES_DB: ${DB_DATABASE}
          POSTGRES_USER: ${DB_USERNAME}
          POSTGRES_PASSWORD: ${DB_PASSWORD}
        ports:
          - "${DB_PORT:-5432}:5432"
        volumes:
          - db-data:/var/lib/postgresql/data
        networks:
          - app-network
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U ${DB_USERNAME}"]
          interval: 10s
          timeout: 5s
          retries: 5

      redis:
        image: redis:alpine
        container_name: ${APP_NAME}-redis
        ports:
          - "${REDIS_PORT:-6379}:6379"
        networks:
          - app-network

    networks:
      app-network:
        driver: bridge
    volumes:
      db-data:
        driver: local

Buat .env.example ($GOLANG/.env.example):

    APP_NAME=PROJECT_NAME
    APP_PORT=8080
    DB_DATABASE=PROJECT_NAME
    DB_USERNAME=PROJECT_NAME
    DB_PASSWORD=secret
    DB_PORT=5432
    REDIS_PORT=6379

---

## Setup Project Golang

    new-project golang nama-project
    # Atau manual:
    cd ~/Developer/projects/standalone/golang
    mkdir nama-project && cd nama-project

    cp -r ~/Developer/tools/templates/backend/golang/docker .
    cp ~/Developer/tools/templates/backend/golang/docker-compose.yml .
    cp ~/Developer/tools/templates/backend/golang/.env.example .env

    dcub
    docker compose exec app go mod tidy

---

## Perintah Golang Sehari-hari

    # Di dalam container
    docker compose exec app go mod tidy        # Download + cleanup dependencies
    docker compose exec app go run main.go     # Jalankan tanpa compile
    docker compose exec app go build -o main . # Compile ke binary
    docker compose exec app go test ./...      # Jalankan semua tests
    docker compose exec app go fmt ./...       # Format kode otomatis
    docker compose exec app go vet ./...       # Cek masalah di kode
    docker compose exec app go get <package>   # Install package baru

    # Di lokal (kalau Go terinstall)
    go mod init myapp          # Init module baru
    go mod tidy                # Download + cleanup
    go run main.go             # Jalankan
    go build -o main .         # Compile
    go test ./...              # Test semua
    go fmt ./...               # Format

---

## Struktur Project Golang (Rekomendasi)

    nama-project/
    ├── main.go              # Entry point
    ├── go.mod               # Module definition
    ├── go.sum               # Dependency checksums
    ├── .env                 # Environment variables
    ├── docker-compose.yml
    ├── Dockerfile
    ├── docker/
    │   └── nginx.conf
    ├── internal/
    │   ├── handlers/        # HTTP handlers (seperti Controller)
    │   ├── models/          # Data models
    │   ├── repository/      # Database queries
    │   └── services/        # Business logic
    └── pkg/
        └── middleware/      # HTTP middleware

---

## Popular Go Frameworks & Libraries

    Web Framework:
    - gin-gonic/gin      → paling populer, cepat, mirip Express
    - labstack/echo      → alternatif gin, lebih clean API
    - gofiber/fiber      → Express-inspired, sangat cepat

    Database:
    - lib/pq             → PostgreSQL driver
    - go-gorm/gorm       → ORM populer (seperti Eloquent)
    - jmoiron/sqlx       → SQL + struct mapping

    Auth:
    - golang-jwt/jwt     → JWT authentication

    Utility:
    - joho/godotenv      → load .env file
    - go-playground/validator → request validation
