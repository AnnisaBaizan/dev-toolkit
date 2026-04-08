# 🐳 Docker — Konsep & Penggunaan
> Referensi: 03-templates.md untuk template | 07-reference.md untuk cheatsheet

---

## Konsep Dasar

### Container
Kotak isolasi untuk satu aplikasi. Tiap project punya container sendiri — tidak konflik antar project.

    Mac kamu
    ├── Container Laravel   (PHP 8.3, MySQL, Redis)   → localhost:8080
    ├── Container Django    (Python 3.12, PostgreSQL)  → localhost:8000
    └── Container React     (Node 20)                 → localhost:5173

### Image
Blueprint untuk membuat container. Didownload dari Docker Hub otomatis saat pertama kali dipakai.

    docker pull php:8.3-fpm      # Download image PHP
    docker pull mysql:8.0        # Download image MySQL
    docker images                # Lihat semua image yang ada

### Volume
Penyimpanan permanen untuk container. Data database tersimpan di volume — tidak hilang meski container dihapus.

    volumes:
      db-data:          # Nama volume
        driver: local   # Simpan di Mac

### Network
Jaringan internal antar container. Container dalam satu network bisa saling ngobrol pakai nama container.

    Container Laravel  →  konek ke "db"  →  Container MySQL
    (bukan 127.0.0.1, tapi nama container "db")

### docker-compose.yml
File orkestrator — definisikan semua container dalam satu file. Satu perintah jalankan semuanya.

---

## Install Docker Desktop

    brew install --cask docker
    open /Applications/Docker.app

Tunggu ikon 🐳 di menu bar berhenti animasi = Docker siap.

    docker --version           # Docker version 29.3.1
    docker compose version     # Docker Compose version v5.1.0
    docker run hello-world     # Test — harusnya muncul "Hello from Docker!"

---

## Perintah Sehari-hari

    # ── Start / Stop ──────────────────────────────────
    dcu                               # docker compose up -d
    dcub                              # docker compose up -d --build
    dcd                               # docker compose down
    docker compose down -v            # Stop + hapus volumes (data hilang!) ⚠️
    docker compose restart            # Restart semua container
    docker compose restart app        # Restart container tertentu

    # ── Status & Logs ─────────────────────────────────
    dcp                               # docker compose ps
    docker ps                         # Semua container yang jalan
    dcl                               # docker compose logs -f
    docker compose logs -f app        # Logs container tertentu

    # ── Masuk Container ───────────────────────────────
    dce bash                          # docker compose exec app bash
    docker compose exec db mysql -u root -p

    # ── Jalankan Perintah (Laravel) ───────────────────
    art migrate                       # php artisan migrate
    art make:model Post -mcr          # php artisan make:model
    art route:list                    # php artisan route:list
    art cache:clear                   # php artisan cache:clear
    comp install                      # composer install
    comp require laravel/sanctum      # composer require

    # ── Cleanup ───────────────────────────────────────
    docker system prune               # Hapus semua yang tidak dipakai
    docker image prune                # Hapus image tidak dipakai
    docker volume prune               # Hapus volume tidak dipakai ⚠️

---

## Struktur docker-compose.yml

    services:
      app:                     # Nama container (bebas)
        build: .               # Build dari Dockerfile di folder ini
        ports:
          - "8080:80"          # host:container
        volumes:
          - .:/var/www         # folder Mac : folder container (sync realtime!)
        environment:
          - APP_ENV=local
        depends_on:
          - db                 # Tunggu db siap dulu
        networks:
          - app-network

      db:
        image: mysql:8.0       # Pakai image langsung (tidak perlu Dockerfile)
        platform: linux/amd64  # Wajib untuk M1!
        environment:
          MYSQL_DATABASE: ${DB_DATABASE}
          MYSQL_USER: ${DB_USERNAME}
          MYSQL_PASSWORD: ${DB_PASSWORD}
          MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
        ports:
          - "${DB_PORT:-3306}:3306"
        volumes:
          - db-data:/var/lib/mysql   # Data tersimpan permanen di volume
        healthcheck:
          test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
          interval: 10s
          timeout: 5s
          retries: 5

    networks:
      app-network:
        driver: bridge

    volumes:
      db-data:
        driver: local

---

## Penting untuk M1 (Apple Silicon)

Beberapa image Docker belum punya versi ARM64 native — tambahkan:

    platform: linux/amd64

Di service yang bermasalah (biasanya MySQL). Docker di M1 handle ini
lewat Rosetta emulation secara otomatis.

---

## Troubleshooting

### Port already in use
    lsof -i :3306         # Cari proses yang pakai port
    kill -9 <PID>         # Kill proses
    # Atau ganti port di .env project:
    DB_PORT=3307

### Container tidak mau start
    dcl                   # Lihat error di logs
    dcd && dcub           # Stop lalu rebuild

### Database tidak bisa diakses
    dcp                   # Cek status — tunggu sampai "healthy"
    # Kalau db belum healthy, tunggu 30 detik lalu coba lagi:
    art migrate

### Volume/database corrupt
    docker compose down -v   # Hapus semua termasuk data ⚠️
    dcub                     # Rebuild fresh
    # Data hilang! Backup dulu sebelum ini.

### Permission error di Laravel
    dce bash
    chmod -R 775 storage bootstrap/cache
    chown -R www-data:www-data storage bootstrap/cache

### Mac M1 — image tidak compatible
    # Tambah di docker-compose.yml:
    platform: linux/amd64

---

## Tips

- Jangan jalankan 2 project dengan port sama bersamaan
- Selalu dcd setelah selesai kerja — hemat memory Mac
- Gunakan dcl untuk debug kalau ada yang tidak jalan
- Volume data aman meski container di-restart — hanya hilang kalau docker compose down -v
