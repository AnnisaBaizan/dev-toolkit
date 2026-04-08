# 🔗 Fullstack — Menghubungkan Frontend & Backend
> Referensi: 04-stacks/ untuk setup tiap stack | 03-templates.md untuk script

---

## Konsep

    Browser → Frontend (React/Vue/Next) → HTTP Request → Backend API → Database
              localhost:5173                              localhost:8000

Frontend dan backend jalan di port berbeda — dihubungkan lewat HTTP API.
Frontend tidak punya database sendiri — semua data dari backend.

---

## Struktur Folder Fullstack Project

    ~/Developer/projects/fullstack/toko-app/
    ├── frontend/                    # React/Vue/Next.js
    │   ├── src/
    │   ├── .env                     # VITE_API_URL=http://localhost:8000
    │   ├── docker-compose.yml
    │   └── package.json
    ├── backend/                     # Laravel/FastAPI/Django
    │   ├── .env                     # FRONTEND_URL=http://localhost:5173
    │   ├── docker-compose.yml
    │   └── ...kode project
    └── Makefile                     # Shortcut jalankan keduanya sekaligus

---

## Makefile — Jalankan Semua Sekaligus

Buat file Makefile di root folder fullstack project:

    up:
    	cd backend && docker compose up -d
    	cd frontend && npm run dev

    down:
    	cd backend && docker compose down

    build:
    	cd backend && docker compose up -d --build
    	cd frontend && npm install && npm run dev

    .PHONY: up down build

Cara pakai:

    cd ~/Developer/projects/fullstack/toko-app
    make up      # Start backend + frontend sekaligus
    make down    # Stop backend
    make build   # Build backend + install frontend

---

## CORS — Wajib Dikonfigurasi di Backend

Browser memblokir request dari origin berbeda (beda port = beda origin).
Backend HARUS izinkan request dari frontend — tanpa ini frontend tidak bisa akses API.

### Laravel

    # config/cors.php
    'allowed_origins' => [env('FRONTEND_URL', 'http://localhost:5173')],
    'allowed_methods' => ['*'],
    'allowed_headers' => ['*'],

    # .env Laravel
    FRONTEND_URL=http://localhost:5173

### FastAPI

    # main.py
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[os.getenv("FRONTEND_URL", "http://localhost:5173")],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # .env FastAPI
    FRONTEND_URL=http://localhost:5173

### Django

    # settings.py
    INSTALLED_APPS = ['corsheaders', ...]
    MIDDLEWARE = ['corsheaders.middleware.CorsMiddleware', ...]
    CORS_ALLOWED_ORIGINS = [os.getenv("FRONTEND_URL", "http://localhost:5173")]

    # .env Django
    FRONTEND_URL=http://localhost:5173

### Node.js Express

    // index.js
    app.use(cors({
        origin: process.env.FRONTEND_URL || 'http://localhost:5173'
    }))

    # .env Node
    FRONTEND_URL=http://localhost:5173

### Golang (Gin)

    // main.go
    r.Use(cors.New(cors.Config{
        AllowOrigins: []string{os.Getenv("FRONTEND_URL")},
        AllowMethods: []string{"GET", "POST", "PUT", "DELETE"},
        AllowHeaders: []string{"Origin", "Content-Type", "Authorization"},
    }))

---

## Setup Frontend untuk Konek ke Backend

### .env di Project Frontend

    # React, Vue, Svelte (Vite-based)
    VITE_API_URL=http://localhost:8000

    # Next.js
    NEXT_PUBLIC_API_URL=http://localhost:8000

    # Nuxt.js
    NUXT_PUBLIC_API_URL=http://localhost:8000

### Axios Instance (React/Vue)

Buat file src/services/api.js:

    import axios from 'axios'

    const api = axios.create({
        baseURL: import.meta.env.VITE_API_URL,
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }
    })

    // Auto tambah token di setiap request
    api.interceptors.request.use(config => {
        const token = localStorage.getItem('token')
        if (token) {
            config.headers.Authorization = 'Bearer ' + token
        }
        return config
    })

    export default api

Cara pakai di component:

    import api from '../services/api'

    // GET
    const { data } = await api.get('/api/products')

    // POST
    const { data } = await api.post('/api/products', { name: 'Baju' })

    // PUT
    const { data } = await api.put('/api/products/1', { name: 'Celana' })

    // DELETE
    await api.delete('/api/products/1')

---

## Authentication — JWT Flow

    1. User login di Frontend
       POST /api/login {email, password}

    2. Backend verifikasi → return JWT token
       { token: "eyJ..." }

    3. Frontend simpan token
       localStorage.setItem('token', token)

    4. Request selanjutnya kirim token di header
       Authorization: Bearer eyJ...

    5. Backend verifikasi token → return data

### Laravel Sanctum (API Token)

    # Install
    comp require laravel/sanctum
    art vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
    art migrate

    # routes/api.php
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/user', fn(Request $r) => $r->user());
        Route::apiResource('products', ProductController::class);
    });

### FastAPI JWT

    from fastapi.security import OAuth2PasswordBearer
    from jose import jwt

    oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

    @app.post("/token")
    async def login(form_data: OAuth2PasswordRequestForm = Depends()):
        # Verifikasi user
        token = jwt.encode({"sub": user.email}, SECRET_KEY)
        return {"access_token": token, "token_type": "bearer"}

---

## Ports — Jangan Konflik!

    Backend Laravel      → 8080
    Backend FastAPI      → 8000
    Backend Django       → 8000  (ganti ke 8001 kalau jalan bersamaan FastAPI)
    Backend Flask        → 5000
    Backend Node.js      → 3000
    Backend Golang       → 8080  (ganti kalau jalan bersamaan Laravel)
    Frontend React/Vue   → 5173
    Frontend Next/Nuxt   → 3000  (ganti ke 3001 kalau jalan bersamaan Node)
    MySQL                → 3306
    PostgreSQL           → 5432
    Redis                → 6379

Tips: Kalau 2 project pakai port sama, ganti di file .env salah satunya.

---

## Fullstack Template yang Tersedia

    ~/Developer/tools/templates/fullstack/
    ├── laravel-react/     # Laravel API + React frontend
    ├── laravel-vue/       # Laravel API + Vue frontend
    ├── laravel-nuxt/      # Laravel API + Nuxt frontend
    ├── fastapi-react/     # FastAPI + React frontend
    ├── fastapi-vue/       # FastAPI + Vue frontend
    ├── django-react/      # Django + React frontend
    └── django-vue/        # Django + Vue frontend

Semua template fullstack belum diisi — ikuti panduan di atas
untuk setup manual, atau kombinasikan template backend + frontend
yang sudah ada.
