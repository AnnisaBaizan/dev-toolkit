# 📋 Scripts — migrate-project & new-project
> Referensi: 04-stacks/ untuk detail tiap stack | 02-docker.md untuk Docker

---

## Dua Script, Dua Tujuan

    migrate-project  → project SUDAH ADA di GitHub/lokal → tambah Docker → jalan
    new-project      → project BARU dari nol → install framework → jalan

Lokasi script:

    ~/Developer/tools/scripts/
    ├── migrate-project.sh
    └── new-project.sh

---

## migrate-project — Untuk Project yang Sudah Ada

Tujuan utama: migrate project Laravel/CodeIgniter dari Windows (Laragon)
ke Mac dengan Docker — otomatis tanpa setup manual.

### Cara Pakai

    # Clone dari GitHub
    migrate-project clone laravel      git@github.com:user/repo.git
    migrate-project clone codeigniter  git@github.com:user/repo.git
    migrate-project clone fastapi-react git@github.com:user/backend.git

    # Dari folder lokal (sudah ada di Mac)
    migrate-project local laravel      ~/Downloads/my-project
    migrate-project local codeigniter  ~/Desktop/ci-app

### Yang Dilakukan Script Otomatis

Laravel / CodeIgniter:

    ✅ Clone dari GitHub ATAU copy dari lokal
    ✅ Copy docker files dari template
    ✅ Buat .env dari .env.example
    ✅ Fix DB_HOST=localhost → DB_HOST=db (wajib untuk Docker!)
    ✅ Fix REDIS_HOST=localhost → REDIS_HOST=redis
    ✅ PAUSE — tunggu kamu cek .env dulu
    ✅ docker compose up --build
    ✅ composer install
    ✅ php artisan key:generate
    ✅ php artisan migrate
    ✅ Set permissions storage/
    ✅ Tanya apakah mau jalankan seeder
    ✅ Buka di Cursor

FastAPI + React:

    ✅ Clone backend ke subfolder /backend
    ✅ Copy docker files
    ✅ Setup .env
    ✅ docker compose up --build (backend)
    ✅ npm install (frontend)
    ✅ Buka di Cursor

### Hasil Struktur Folder

Laravel / CodeIgniter:

    ~/Developer/projects/standalone/php/nama-project/
    ├── docker/
    │   ├── nginx.conf
    │   └── php/Dockerfile
    ├── docker-compose.yml
    ├── .env                ← sudah dikonfigurasi otomatis
    └── ... (kode project kamu)

FastAPI + React:

    ~/Developer/projects/fullstack/nama-project/
    ├── backend/            ← FastAPI
    │   ├── docker/
    │   ├── docker-compose.yml
    │   └── .env
    └── frontend/           ← React

### Catatan Penting

Script akan PAUSE setelah setup .env — ini kesempatan untuk
sesuaikan konfigurasi sebelum Docker dijalankan.
Tekan Enter kalau sudah yakin .env sudah benar.

---

## new-project — Untuk Project Baru dari Nol

### Cara Pakai

    # Backend
    new-project laravel      nama-project
    new-project codeigniter  nama-project
    new-project django       nama-project
    new-project flask        nama-project
    new-project fastapi      nama-project
    new-project node         nama-project
    new-project golang       nama-project

    # Frontend
    new-project react        nama-project
    new-project vue          nama-project
    new-project nextjs       nama-project
    new-project nuxtjs       nama-project
    new-project svelte       nama-project
    new-project angular      nama-project

    # Lihat semua project
    new-project list

### Yang Dilakukan Script Otomatis

    ✅ Buat folder di lokasi yang tepat
    ✅ Copy docker files dari template
    ✅ Setup .env dari .env.example
    ✅ Install framework (Laravel/CodeIgniter/React/Vue/Next.js)
    ✅ Buka di Cursor

### Template Status

    Stack        | Template      | Script
    -------------|---------------|--------
    Laravel      | ✅ Ready      | ✅ Ready
    CodeIgniter  | 📄 Lihat php.md | ✅ Ready
    Django       | 📄 Lihat python.md | ✅ Ready
    Flask        | 📄 Lihat python.md | ✅ Ready
    FastAPI      | 📄 Lihat python.md | ✅ Ready
    Node.js      | 📄 Lihat javascript.md | ✅ Ready
    Golang       | 📄 Lihat golang.md | ✅ Ready
    React        | 📄 Lihat javascript.md | ✅ Ready
    Vue          | 📄 Lihat javascript.md | ✅ Ready
    Next.js      | 📄 Lihat javascript.md | ✅ Ready
    Nuxt.js      | 📄 Lihat javascript.md | ✅ Ready
    Svelte       | 📄 Lihat javascript.md | ✅ Ready
    Angular      | 📄 Lihat javascript.md | ✅ Ready

---

## Perbedaan migrate-project vs new-project

    migrate-project clone laravel <url>
    → git clone repo
    → copy docker files dari template
    → setup .env
    → composer install        ← existing code

    new-project laravel nama
    → buat folder baru
    → copy docker files dari template
    → setup .env
    → composer create-project ← fresh install

---

## Menambah Template Baru

Kalau mau tambah template stack yang belum ada:

    # 1. Buat folder template
    mkdir -p ~/Developer/tools/templates/backend/<stack>/docker

    # 2. Buat minimal 3 file:
    #    - Dockerfile
    #    - docker-compose.yml
    #    - .env.example

    # 3. Ikuti panduan di docs/04-stacks/<lang>.md

    # 4. Test
    new-project <stack> test-project
