# 🐍 Python Stacks — Django, Flask, FastAPI
> Referensi: 02-docker.md untuk konsep Docker | 03-templates.md untuk script

Semua Python stack pakai PostgreSQL + Redis.

---

## Perbandingan Django vs Flask vs FastAPI

    Django                Flask               FastAPI
    ──────────────────────────────────────────────────────
    Full framework        Micro framework     Modern & async
    Seperti Laravel       Seperti Lumen       REST API focused

    Built-in:             Pilih sendiri:      Built-in:
    - ORM                 - ORM               - Auto docs (Swagger)
    - Admin panel         - Auth              - Type hints
    - Auth                - dll               - Async support
    - Forms                                   - Validasi otomatis

    Cocok untuk:          Cocok untuk:        Cocok untuk:
    Web app lengkap       API kecil           REST API modern
    CMS, E-commerce       Prototype cepat     Microservice
    Admin dashboard       Tools internal      AI/ML API

---

## Django

Template: 📄 Belum dibuat
Stack: Python 3.12 + Nginx + PostgreSQL 16 + Redis
Port default: 8000

### Buat Template Django

    DJANGO=~/Developer/tools/templates/backend/django
    mkdir -p $DJANGO/docker

Buat Dockerfile ($DJANGO/Dockerfile):

    FROM python:3.12-slim
    ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
    WORKDIR /app
    RUN apt-get update && apt-get install -y gcc libpq-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    RUN adduser --disabled-password --gecos '' appuser \
        && chown -R appuser:appuser /app
    USER appuser
    EXPOSE 8000
    CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

Buat requirements.txt ($DJANGO/requirements.txt):

    django>=5.0,<6.0
    psycopg2-binary>=2.9
    python-dotenv>=1.0
    djangorestframework>=3.15
    django-cors-headers>=4.3
    django-redis>=5.4
    celery>=5.3
    redis>=5.0
    whitenoise>=6.6

Buat docker/nginx.conf ($DJANGO/docker/nginx.conf):

    upstream django { server app:8000; }
    server {
        listen 80;
        client_max_body_size 100M;
        location / {
            proxy_pass http://django;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location /static/ { alias /app/staticfiles/; }
        location /media/ { alias /app/media/; }
    }

Buat docker-compose.yml ($DJANGO/docker-compose.yml):

    services:
      app:
        build: .
        container_name: ${APP_NAME}-django
        restart: unless-stopped
        volumes:
          - .:/app
        environment:
          - DEBUG=${DEBUG:-True}
          - SECRET_KEY=${SECRET_KEY:-changeme}
          - DATABASE_URL=postgres://${DB_USERNAME}:${DB_PASSWORD}@db:5432/${DB_DATABASE}
          - REDIS_URL=redis://redis:6379/0
        depends_on:
          db:
            condition: service_healthy
        networks:
          - app-network

      nginx:
        image: nginx:alpine
        container_name: ${APP_NAME}-nginx
        ports:
          - "${NGINX_PORT:-8000}:80"
        volumes:
          - .:/app
          - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf
        depends_on:
          - app
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

Buat .env.example ($DJANGO/.env.example):

    APP_NAME=PROJECT_NAME
    DEBUG=True
    SECRET_KEY=changeme
    NGINX_PORT=8000
    DB_DATABASE=PROJECT_NAME
    DB_USERNAME=PROJECT_NAME
    DB_PASSWORD=secret
    DB_PORT=5432
    REDIS_PORT=6379

### Setup Project Django

    dcub
    docker compose exec app django-admin startproject mysite .
    docker compose exec app python manage.py migrate
    docker compose exec app python manage.py createsuperuser

### Perintah Django Sehari-hari

    docker compose exec app python manage.py runserver
    docker compose exec app python manage.py migrate
    docker compose exec app python manage.py makemigrations
    docker compose exec app python manage.py createsuperuser
    docker compose exec app python manage.py shell
    docker compose exec app python manage.py startapp blog
    docker compose exec app python manage.py collectstatic
    docker compose exec app python manage.py test

### Konfigurasi settings.py untuk Docker

    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'HOST': 'db',           # nama container, BUKAN localhost!
            'NAME': os.getenv('DB_DATABASE'),
            'USER': os.getenv('DB_USERNAME'),
            'PASSWORD': os.getenv('DB_PASSWORD'),
            'PORT': '5432',
        }
    }

    CACHES = {
        'default': {
            'BACKEND': 'django_redis.cache.RedisCache',
            'LOCATION': 'redis://redis:6379/0',   # nama container redis
        }
    }

---

## Flask

Template: 📄 Belum dibuat
Stack: Python 3.12 + Nginx + PostgreSQL 16 + Redis
Port default: 5000

### Buat Template Flask

    FLASK=~/Developer/tools/templates/backend/flask
    mkdir -p $FLASK/docker

Buat Dockerfile ($FLASK/Dockerfile):

    FROM python:3.12-slim
    ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
    WORKDIR /app
    RUN apt-get update && apt-get install -y gcc libpq-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    RUN adduser --disabled-password --gecos '' appuser \
        && chown -R appuser:appuser /app
    USER appuser
    EXPOSE 5000
    CMD ["flask", "run", "--host=0.0.0.0", "--reload"]

Buat requirements.txt ($FLASK/requirements.txt):

    flask>=3.0
    flask-sqlalchemy>=3.1
    flask-migrate>=4.0
    flask-cors>=4.0
    psycopg2-binary>=2.9
    python-dotenv>=1.0
    redis>=5.0
    gunicorn>=21.0

Buat entry point ($FLASK/app.py):

    from flask import Flask, jsonify
    from flask_cors import CORS
    import os

    app = Flask(__name__)
    CORS(app, origins=[os.getenv("FRONTEND_URL", "http://localhost:5173")])

    @app.route('/')
    def index():
        return jsonify({"message": "Flask API running!", "status": "ok"})

    @app.route('/api/health')
    def health():
        return jsonify({"status": "healthy"})

    if __name__ == '__main__':
        app.run(host='0.0.0.0', port=5000, debug=True)

---

## FastAPI

Template: 📄 Belum dibuat
Stack: Python 3.12 + Nginx + PostgreSQL 16 + Redis
Port default: 8000

### Buat Template FastAPI

    FASTAPI=~/Developer/tools/templates/backend/fastapi
    mkdir -p $FASTAPI/docker

Buat Dockerfile ($FASTAPI/Dockerfile):

    FROM python:3.12-slim
    ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
    WORKDIR /app
    RUN apt-get update && apt-get install -y gcc libpq-dev \
        && apt-get clean && rm -rf /var/lib/apt/lists/*
    COPY requirements.txt .
    RUN pip install --no-cache-dir -r requirements.txt
    COPY . .
    RUN adduser --disabled-password --gecos '' appuser \
        && chown -R appuser:appuser /app
    USER appuser
    EXPOSE 8000
    CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

Buat requirements.txt ($FASTAPI/requirements.txt):

    fastapi>=0.110
    uvicorn[standard]>=0.27
    sqlalchemy>=2.0
    alembic>=1.13
    psycopg2-binary>=2.9
    python-dotenv>=1.0
    redis>=5.0
    python-jose[cryptography]>=3.3
    passlib[bcrypt]>=1.7

Buat entry point ($FASTAPI/main.py):

    from fastapi import FastAPI
    from fastapi.middleware.cors import CORSMiddleware
    import os

    app = FastAPI(
        title="My API",
        description="FastAPI project",
        version="1.0.0"
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=[os.getenv("FRONTEND_URL", "http://localhost:5173")],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @app.get("/")
    def root():
        return {"message": "FastAPI running!", "status": "ok"}

    @app.get("/api/health")
    def health():
        return {"status": "healthy"}

Keunggulan FastAPI:
- Auto-generate dokumentasi API di http://localhost:8000/docs (Swagger UI)
- Auto-generate ReDoc di http://localhost:8000/redoc
- Tanpa konfigurasi tambahan!

---

## Tips Umum Python Stack

Virtual environment tidak diperlukan karena semua jalan di Docker container.
Docker container sudah isolated — seperti virtual environment tapi lebih powerful.

Kalau mau jalankan script Python di luar Docker (lokal):

    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    python script.py
    deactivate
