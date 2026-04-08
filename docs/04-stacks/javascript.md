# ⚡ JavaScript Stacks
> Referensi: 05-fullstack.md untuk koneksi ke backend | 02-docker.md untuk Docker

---

## Overview — Frontend vs Backend

    Frontend (tampilan browser):
    ├── React        → paling populer, Meta
    ├── Vue 3        → mudah dipelajari, progressive
    ├── Next.js      → React + SSR + routing
    ├── Nuxt.js      → Vue + SSR + routing
    ├── Svelte       → compile ke vanilla JS, sangat cepat
    └── Angular      → enterprise, Google, TypeScript

    Backend (server, logic, database):
    └── Node.js + Express → JavaScript di server + MongoDB + Redis

    SSR  = Server Side Rendering → HTML dirender di server (bagus untuk SEO)
    SPA  = Single Page Application → HTML dirender di browser
    SSG  = Static Site Generation → HTML dibuat saat build

---

## React

Template: 📄 Belum dibuat
Stack: React 18 + Vite + Node 20
Port default: 5173
Cocok untuk: Dashboard, admin panel, app yang tidak butuh SEO

### Setup Project Baru

    new-project react nama-project
    # Atau manual:
    cd ~/Developer/projects/standalone/javascript
    mkdir nama-project && cd nama-project
    npm create vite@latest . -- --template react
    npm install
    npm install axios react-router-dom @tanstack/react-query

### Jalankan

    npm run dev      # Dev server → http://localhost:5173
    npm run build    # Build production
    npm run preview  # Preview hasil build

### Struktur Folder Rekomendasi

    src/
    ├── components/     # Reusable UI components
    ├── pages/          # Halaman/route
    ├── hooks/          # Custom React hooks
    ├── services/       # API calls (axios)
    ├── store/          # State management
    └── utils/          # Helper functions

### .env.example

    VITE_API_URL=http://localhost:8000

### Contoh Fetch Data dari Backend

    // src/services/api.js
    import axios from 'axios'

    const api = axios.create({
        baseURL: import.meta.env.VITE_API_URL,
        headers: { 'Content-Type': 'application/json' }
    })

    export default api

    // Di component
    import { useEffect, useState } from 'react'
    import api from '../services/api'

    function Products() {
        const [products, setProducts] = useState([])

        useEffect(() => {
            api.get('/api/products')
               .then(res => setProducts(res.data))
        }, [])

        return products.map(p => <div key={p.id}>{p.name}</div>)
    }

---

## Vue 3

Template: 📄 Belum dibuat
Stack: Vue 3 + Vite + Node 20
Port default: 5173
Cocok untuk: Web app, dashboard, lebih mudah dari React untuk pemula

### Setup Project Baru

    new-project vue nama-project
    # Atau manual:
    npm create vite@latest . -- --template vue
    npm install
    npm install axios vue-router@4 pinia

### Jalankan

    npm run dev      # Dev server → http://localhost:5173
    npm run build    # Build production

### .env.example

    VITE_API_URL=http://localhost:8000

### Contoh Fetch Data dari Backend

    // composables/useProducts.js
    import { ref } from 'vue'
    import axios from 'axios'

    const api = axios.create({
        baseURL: import.meta.env.VITE_API_URL
    })

    export const useProducts = () => {
        const products = ref([])

        const fetchProducts = async () => {
            const { data } = await api.get('/api/products')
            products.value = data
        }

        return { products, fetchProducts }
    }

---

## Next.js

Template: 📄 Belum dibuat
Stack: Next.js 14 + Node 20
Port default: 3000
Cocok untuk: Website yang butuh SEO (blog, landing page, e-commerce)

Kapan pakai Next.js vs React biasa?
- Next.js  → butuh SEO, landing page, blog, e-commerce
- React    → dashboard, admin panel, tidak butuh SEO

### Setup Project Baru

    new-project nextjs nama-project
    # Atau manual:
    npx create-next-app@latest . \
      --typescript \
      --tailwind \
      --eslint \
      --app \
      --src-dir \
      --import-alias "@/*"

### Jalankan

    npm run dev      # Dev server → http://localhost:3000
    npm run build    # Build production
    npm run start    # Jalankan production build

### .env.example

    NEXT_PUBLIC_API_URL=http://localhost:8000

---

## Nuxt.js

Template: 📄 Belum dibuat
Stack: Nuxt 3 + Node 20
Port default: 3000
Cocok untuk: Vue + SSR, seperti Next.js tapi untuk Vue

### Setup Project Baru

    new-project nuxtjs nama-project
    # Atau manual:
    npx nuxi@latest init .
    npm install

### Jalankan

    npm run dev      # Dev server → http://localhost:3000
    npm run build    # Build production

### .env.example

    NUXT_PUBLIC_API_URL=http://localhost:8000

---

## SvelteKit

Template: 📄 Belum dibuat
Stack: SvelteKit + Node 20
Port default: 5173
Cocok untuk: Web app ringan, sintaks paling mudah di antara semua framework

Keunggulan Svelte:
- Compile ke vanilla JS — tidak ada virtual DOM
- Lebih cepat dari React/Vue di runtime
- Sintaks paling simpel dan mudah dipelajari

### Setup Project Baru

    new-project svelte nama-project
    # Atau manual:
    npx sv create .
    # Pilih: SvelteKit minimal → TypeScript → ESLint + Prettier
    npm install

### Jalankan

    npm run dev      # Dev server → http://localhost:5173
    npm run build    # Build production

---

## Angular

Template: 📄 Belum dibuat
Stack: Angular 17+ + Node 20
Port default: 4200
Cocok untuk: Enterprise app besar, TypeScript by default

Kapan pakai Angular?
- Kerja di perusahaan enterprise atau bank
- Tim besar yang butuh struktur ketat
- Project yang pakai TypeScript dari awal

### Setup Project Baru

    new-project angular nama-project
    # Atau manual:
    npm install -g @angular/cli
    ng new nama-project --routing --style=scss
    cd nama-project

### Jalankan

    ng serve         # Dev server → http://localhost:4200
    ng build         # Build production
    ng generate component nama    # Buat component baru
    ng generate service nama      # Buat service baru

---

## Node.js + Express

Template: 📄 Belum dibuat
Stack: Node 20 + Express + MongoDB + Redis
Port default: 3000
Cocok untuk: REST API, backend JavaScript, pasangan alami dengan MongoDB

### Buat Template Node.js

    NODE=~/Developer/tools/templates/backend/node
    mkdir -p $NODE/docker

Buat Dockerfile ($NODE/Dockerfile):

    FROM node:20-alpine
    WORKDIR /app
    COPY package*.json ./
    RUN npm ci --only=production
    COPY . .
    RUN adduser -D appuser && chown -R appuser:appuser /app
    USER appuser
    EXPOSE 3000
    CMD ["node", "src/index.js"]

Buat package.json dependencies:

    {
      "dependencies": {
        "express": "^4.18",
        "mongoose": "^8.0",
        "redis": "^4.6",
        "dotenv": "^16.0",
        "cors": "^2.8",
        "bcryptjs": "^2.4",
        "jsonwebtoken": "^9.0",
        "morgan": "^1.10"
      },
      "devDependencies": {
        "nodemon": "^3.0"
      }
    }

Buat entry point (src/index.js):

    const express = require('express')
    const cors = require('cors')
    require('dotenv').config()

    const app = express()
    const PORT = process.env.PORT || 3000

    app.use(cors({
        origin: process.env.FRONTEND_URL || 'http://localhost:5173'
    }))
    app.use(express.json())

    app.get('/', (req, res) => {
        res.json({ message: 'Express API running!', status: 'ok' })
    })

    app.get('/api/health', (req, res) => {
        res.json({ status: 'healthy' })
    })

    app.listen(PORT, () => console.log('Server running on port ' + PORT))

### Jalankan

    dcu              # docker compose up -d
    dcl              # lihat logs

---

## npm Cheatsheet

    npm install                  # Install semua dari package.json
    npm install <package>        # Install package baru
    npm install -D <package>     # Install devDependency
    npm uninstall <package>      # Hapus package
    npm run dev                  # Dev server
    npm run build                # Build production
    npm run preview              # Preview hasil build
    npm update                   # Update semua package
    npx <command>                # Jalankan tanpa install global
    npm list                     # Lihat semua package terinstall
