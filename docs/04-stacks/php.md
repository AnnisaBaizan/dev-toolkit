# 🐘 PHP Stacks — Laravel & CodeIgniter
> Referensi: 02-docker.md untuk konsep Docker | 03-templates.md untuk script

---

## Laravel

Template: ✅ Ready di ~/Developer/tools/templates/backend/laravel/
Stack: PHP 8.3 + Nginx + MySQL 8.0 + Redis
Port default: 8080

### Migrate Project yang Sudah Ada

    migrate-project clone laravel git@github.com:user/repo.git
    migrate-project local laravel ~/path/to/project

### Buat Project Baru

    new-project laravel nama-project
    # Akses: http://localhost:8080

### Manual Setup (tanpa script)

    # 1. Clone repo
    cd ~/Developer/projects/standalone/php
    git clone git@github.com:user/repo.git
    cd nama-project

    # 2. Copy docker files dari template
    cp -r ~/Developer/tools/templates/backend/laravel/docker .
    cp ~/Developer/tools/templates/backend/laravel/docker-compose.yml .

    # 3. Setup .env
    cp .env.example .env
    nano .env
    # Wajib ubah:
    # DB_HOST=127.0.0.1 → DB_HOST=db
    # DB_HOST=localhost  → DB_HOST=db
    # REDIS_HOST=127.0.0.1 → REDIS_HOST=redis

    # 4. Start Docker
    dcub    # docker compose up -d --build

    # 5. Install dependencies
    comp install    # composer install

    # 6. Generate key & migrate
    art key:generate
    art migrate
    art db:seed    # kalau ada seeder

    # 7. Fix permissions
    dce bash
    chmod -R 775 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache

    # 8. Akses
    open http://localhost:8080

### Perintah Laravel Sehari-hari

Semua dijalankan dari folder project (docker-compose.yml harus ada):

    # Artisan shortcuts (pakai alias art)
    art migrate                        # Jalankan migration
    art migrate:fresh                  # Drop semua + migrate ulang
    art migrate:fresh --seed           # Fresh + seed
    art make:model Post -mcr           # Model + migration + controller
    art make:controller Api/PostController --api
    art make:migration create_posts_table
    art make:seeder PostSeeder
    art make:middleware AuthMiddleware
    art make:request StorePostRequest
    art db:seed                        # Jalankan seeder
    art db:seed --class=PostSeeder     # Seeder tertentu
    art route:list                     # Lihat semua route
    art route:list --path=api          # Filter route API
    art cache:clear                    # Clear cache
    art config:clear
    art view:clear
    art optimize:clear                 # Clear semua
    art queue:work                     # Jalankan queue worker
    art queue:listen                   # Listen queue
    art tinker                         # REPL interaktif
    art storage:link                   # Link storage ke public

    # Composer shortcuts (pakai alias comp)
    comp install                       # Install dependencies
    comp require laravel/sanctum       # Install package
    comp require --dev laravel/telescope
    comp update                        # Update semua package
    comp dump-autoload                 # Regenerate autoload

### File Penting Laravel

    app/
    ├── Http/
    │   ├── Controllers/    # Logic handler request
    │   ├── Middleware/     # Filter request
    │   └── Requests/       # Form validation
    ├── Models/             # Database models (Eloquent)
    └── Providers/          # Service providers
    config/                 # Konfigurasi (database, mail, queue, dll)
    database/
    ├── migrations/         # Struktur database
    ├── seeders/            # Data awal
    └── factories/          # Data fake untuk testing
    resources/
    ├── views/              # Template Blade
    ├── css/                # Styling
    └── js/                 # Frontend assets
    routes/
    ├── web.php             # Route untuk web
    └── api.php             # Route untuk API
    storage/                # File upload, logs, cache
    .env                    # Konfigurasi environment (jangan di-commit!)

### Konfigurasi .env untuk Docker

    APP_NAME=nama-project
    APP_ENV=local
    APP_KEY=                    ← generate dengan art key:generate
    APP_DEBUG=true
    APP_URL=http://localhost:8080

    DB_CONNECTION=mysql
    DB_HOST=db                  ← nama container, BUKAN localhost!
    DB_PORT=3306
    DB_DATABASE=nama-project
    DB_USERNAME=nama-project
    DB_PASSWORD=secret

    REDIS_HOST=redis            ← nama container, BUKAN localhost!
    REDIS_PORT=6379

    CACHE_DRIVER=redis
    QUEUE_CONNECTION=redis
    SESSION_DRIVER=redis

### Template Files

    ~/Developer/tools/templates/backend/laravel/
    ├── docker-compose.yml      ← orchestrator semua service
    ├── .env.example            ← template konfigurasi
    └── docker/
        ├── nginx.conf          ← web server config
        └── php/
            └── Dockerfile      ← custom PHP 8.3 image

---

## CodeIgniter

Template: 📄 Belum dibuat — ikuti panduan di bawah
Stack: PHP 8.2 + Nginx + MySQL 8.0 + Redis
Port default: 8081

### Buat Template CodeIgniter

    # Copy dari template Laravel sebagai base
    cp -r ~/Developer/tools/templates/backend/laravel           ~/Developer/tools/templates/backend/codeigniter

    # Edit Dockerfile — ganti versi PHP
    nano ~/Developer/tools/templates/backend/codeigniter/docker/php/Dockerfile
    # Ubah: FROM php:8.3-fpm → FROM php:8.2-fpm

    # Edit docker-compose.yml — ganti port default
    nano ~/Developer/tools/templates/backend/codeigniter/docker-compose.yml
    # Ubah NGINX_PORT default ke 8081

    # Edit .env.example
    nano ~/Developer/tools/templates/backend/codeigniter/.env.example
    # Ganti APP_PORT=8080 → APP_PORT=8081

### Migrate Project yang Sudah Ada

    migrate-project clone codeigniter git@github.com:user/repo.git
    migrate-project local codeigniter ~/path/to/project

### Manual Setup

    cd ~/Developer/projects/standalone/php
    git clone git@github.com:user/repo.git
    cd nama-project

    cp -r ~/Developer/tools/templates/backend/codeigniter/docker .
    cp ~/Developer/tools/templates/backend/codeigniter/docker-compose.yml .

    cp .env.example .env
    nano .env

    dcub
    comp install

### Perintah CodeIgniter Sehari-hari

    # Spark CLI (seperti Artisan di Laravel)
    art spark migrate                  # Jalankan migration (via alias art → php spark)
    # Atau masuk container dulu:
    dce bash
    php spark migrate
    php spark make:controller Blog
    php spark make:model Blog
    php spark make:migration create_blog_table
    php spark routes                   # Lihat semua route
    php spark db:seed                  # Jalankan seeder

### Konfigurasi Database CodeIgniter

    # app/Config/Database.php
    hostname → db          ← nama container, BUKAN localhost!
    database → nama-project
    username → nama-project
    password → secret
    port     → 3306
