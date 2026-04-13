# 🤖 AI Tools — Claude Code, Cursor, agent_config
> Referensi: README.md untuk overview | 01-environment.md untuk instalasi

---

## Overview — 3 Layer AI

    Layer 1 — agent_config (SOP & Rules)
    └── Aturan main untuk semua AI
        CLAUDE.md → Claude Code CLI
        CHAT.md   → Claude.ai browser

    Layer 2 — Claude Code CLI (Terminal AI)
    └── AI di Terminal — analisis seluruh project
        Slash commands dari workflows/

    Layer 3 — Cursor / Antigravity (Editor AI)
    └── AI di dalam editor — autocomplete, inline edit, agent

---

## agent_config

SOP dan workflow untuk semua AI tools kamu.

### Lokasi

    ~/Developer/tools/agent_config/
    ├── SOP.md          → Aturan utama AI (symlink ke ~/.claude/CLAUDE.md)
    ├── CHAT.md         → Versi ringkas untuk claude.ai browser
    └── workflows/      → 16 slash commands (symlink ke ~/.claude/workflows/)

    ~/.claude/
    ├── CLAUDE.md       → symlink ke agent_config/SOP.md
    ├── workflows/      → symlink ke agent_config/workflows/
    └── settings.json   → permissions & preferences

### Isi SOP.md

Aturan yang diterapkan ke Claude Code:
- No hallucination — tidak mengarang jawaban
- No sudo — tidak jalankan perintah berbahaya
- Sequential thinking — berpikir step by step
- Propose first — usulkan dulu sebelum eksekusi
- Anti-contrarian — selalu di sisi user

### Update agent_config

    cd ~/Developer/tools/agent_config
    git pull    # Update ke versi terbaru
    # Perubahan otomatis berlaku karena pakai symlink!

### Setup CHAT.md di Claude.ai

1. Buka claude.ai → Projects → nama project kamu
2. Klik Set Instructions
3. Jalankan: cat ~/Developer/tools/agent_config/CHAT.md
4. Copy isinya → paste ke instructions → Save

Sekarang setiap chat di project itu, Claude ikuti SOP kamu!

---

## Claude Code CLI

AI assistant langsung di Terminal — bisa baca dan analisis seluruh project.

### Info

    Version  : 2.1.86
    Model    : Sonnet 4.6
    Plan     : Claude Pro
    Config   : ~/.claude/CLAUDE.md (symlink ke agent_config/SOP.md)

### Cara Buka

    # Selalu masuk folder project dulu!
    cd ~/Developer/projects/standalone/php/nama-project
    claude

### Slash Commands (dari agent_config/workflows/)

    /plan        → Buat implementation plan sebelum coding
    /debug       → Root cause analysis + self-healing
    /review      → Architectural code QA
    /explain     → Dekomposisi teknis — jelaskan kode
    /commit      → Conventional commit management
    /brainstorm  → Explore solusi sebelum coding
    /task        → Orchestrasi task multi-phase
    /verify      → Evidence-based completion check
    /finish      → Branch completion + cleanup
    /audit       → Security + integrity scan
    /search      → Deep logic discovery di codebase
    /suggest     → Multi-dimensional optimisation
    /ui          → UI/UX design guidance
    /tldr        → Tech-only summary ringkas
    /bootstrap   → Project scaffolding dari docs
    /test        → TDD red-green-refactor cycle

### Tips Penggunaan

Selalu masuk folder project sebelum buka Claude Code:

    cd ~/Developer/projects/standalone/php/toko-online
    dcu      # pastikan Docker jalan dulu
    claude

Tanya spesifik — konteks lebih baik = jawaban lebih baik:

    # Bagus — spesifik dengan konteks
    "Ada bug di AuthController@login, user tidak bisa login
     setelah reset password, error: TokenMismatchException"

    # Kurang bagus — terlalu umum
    "Ada bug di login"

Workflow coding dengan Claude Code:

    /plan "implementasi fitur cart dengan session"
    # Claude buat rencana detail → kamu approve → mulai coding

    /debug "SQLSTATE[42S02]: Table 'laravel.carts' doesn't exist"
    # Claude analisis root cause → propose fix → kamu approve

    /review
    # Claude review seluruh kode → kasih saran improvement

    /commit
    # Claude buat pesan commit sesuai conventional commits

### Resume Session

    # Lanjut session Claude Code sebelumnya
    claude --resume <session-id>

    # Session ID ada di akhir output setelah exit:
    # Resume this session with:
    # claude --resume cda2502f-a92f-4438-a40f-68f1c8e43fc1

---

## Code Editor

Pilih salah satu editor — keduanya berbasis VS Code, AI built-in.

---

## Cursor

AI-powered code editor — VS Code fork dengan Claude Pro via extension.

### Info

    Version    : 2.6.22
    Extension  : Claude Code for VS Code (by Anthropic)
    Plan       : Claude Pro (login via extension)

### Shortcuts

    Cmd K          → AI inline edit — edit kode yang diselect
    Cmd L          → AI chat sidebar — tanya tentang kode
    Cmd Shift I    → AI Composer — edit banyak file sekaligus
    Tab            → Terima AI autocomplete suggestion
    Esc            → Tolak AI suggestion
    Cmd P          → Quick file open
    Cmd Shift P    → Command palette
    Cmd backtick   → Toggle terminal
    Cmd B          → Toggle sidebar
    Cmd /          → Toggle comment
    Cmd D          → Select next occurrence

### Cara Pakai AI di Cursor

Inline Edit (Cmd K):
1. Highlight kode yang mau diubah
2. Tekan Cmd K
3. Ketik instruksi: "tambahkan validasi email"
4. Tekan Enter → AI langsung ubah kode
5. Accept atau Reject hasilnya

Chat Sidebar (Cmd L):
1. Tekan Cmd L
2. Ketik pertanyaan
3. Referensi file dengan @ — contoh:
   "@AuthController jelaskan fungsi login ini"
   "@ProductModel tambahkan relasi ke Category"

Composer (Cmd Shift I):
1. Tekan Cmd Shift I
2. Deskripsikan fitur yang mau dibuat
3. AI buat/edit banyak file sekaligus
4. Review semua perubahan sebelum apply

### Buka Project di Cursor

    cursor .                    # Buka folder aktif
    cursor ~/path/to/project    # Buka folder tertentu

---

## Google Antigravity

Agent-first IDE dari Google — AI model Gemini, Claude, dan GPT tersedia built-in, gratis.

### Info

    Developer  : Google
    Model      : Gemini 3.1 Pro, Claude Sonnet/Opus 4.6, GPT-OSS-120B
    Plan       : Gratis untuk individual (public preview)
    Basis      : VS Code fork

### Tampilan

Antigravity punya 2 view berbeda:
- Editor view  → tampilan IDE biasa (seperti VS Code / Cursor)
- Manager view → orkestrasi banyak AI agent secara paralel (Cmd E untuk toggle)

### Shortcuts

    Cmd I          → AI inline command — ketik instruksi langsung
    Cmd L          → Toggle agent panel
    Cmd E          → Toggle editor ↔ agent manager view
    Tab            → Terima AI autocomplete suggestion
    Esc            → Tolak AI suggestion
    Cmd P          → Quick file open
    Cmd Shift P    → Command palette
    Ctrl backtick  → Toggle terminal
    Cmd B          → Toggle sidebar
    Cmd /          → Toggle comment
    Cmd D          → Select next occurrence

Semua shortcut VS Code standar bekerja tanpa konfigurasi tambahan.

### Cara Pakai AI di Antigravity

Inline Command (Cmd I):
1. Highlight kode yang mau diubah (atau tidak perlu highlight)
2. Tekan Cmd I
3. Ketik instruksi dalam bahasa natural
4. AI langsung ubah kode
5. Accept atau Reject hasilnya

Agent Panel (Cmd L):
1. Tekan Cmd L untuk buka panel agent
2. Ketik task atau pertanyaan
3. Agent AI bisa referensi file dan jalankan aksi di project

Agent Manager (Cmd E):
1. Tekan Cmd E untuk masuk Manager view
2. Buat dan jalankan banyak agent secara paralel
3. Cocok untuk task besar yang bisa dibagi-bagi

### Buka Project di Antigravity

    antigravity .                    # Buka folder aktif (jika CLI tersedia)
    antigravity ~/path/to/project    # Buka folder tertentu

---

## Workflow Developer + AI Sehari-hari

### Mulai Kerja

    # 1. Masuk folder project
    cd ~/Developer/projects/standalone/php/toko-online

    # 2. Start Docker
    dcu

    # 3. Buka editor (pilih salah satu)
    cursor .        # Cursor
    antigravity .   # Google Antigravity

    # 4. Buka Claude Code untuk analisis/planning
    claude

### Coding Fitur Baru

    # Di Claude Code
    /plan "implementasi fitur checkout dengan midtrans"

    # Claude kasih rencana step by step
    # Kamu approve → mulai coding di Cursor

    # Di Cursor, pakai Cmd K untuk:
    # - Generate boilerplate code
    # - Tambah validasi
    # - Refactor fungsi

    # Di Antigravity, pakai Cmd I untuk hal yang sama

### Debug

    # Copy error message
    # Buka Claude Code
    /debug "error message lengkap di sini"

    # Claude analisis → propose fix
    # Apply fix di Cursor

### Sebelum Commit

    # Review kode
    /review

    # Buat commit message
    /commit

    # Di terminal
    gs       # git status
    ga       # git add .
    gci "feat: add checkout with midtrans"
    gp       # git push

### Selesai Kerja

    dcd      # docker compose down
    # Tutup Cursor
