# 📖 Reference — Ports, Aliases, Cheatsheet
> Referensi: 01-environment.md untuk setup | 02-docker.md untuk Docker commands

---

## Ports Reference

    Stack                  | Service   | Port
    -----------------------|-----------|------
    Laravel                | Web       | 8080
    CodeIgniter            | Web       | 8081
    Django                 | Web       | 8000
    Flask                  | Web       | 5000
    FastAPI                | Web       | 8000
    Node.js Express        | Web       | 3000
    Golang                 | Web       | 8080
    React / Vue / Svelte   | Dev       | 5173
    Next.js / Nuxt.js      | Dev       | 3000
    Angular                | Dev       | 4200
    MySQL                  | Database  | 3306
    PostgreSQL             | Database  | 5432
    MongoDB                | Database  | 27017
    Redis                  | Cache     | 6379

PENTING: Jangan jalankan 2 project dengan port sama bersamaan!
Ganti port di file .env project — ubah NGINX_PORT atau DB_PORT.

---

## Semua Aliases Aktif

### Navigation

    dev        → cd ~/Developer
    projects   → cd ~/Developer/projects
    tools      → cd ~/Developer/tools
    docs       → cd ~/Developer/tools/docs

### Scripts

    new-project      → ~/Developer/tools/scripts/new-project.sh
    migrate-project  → ~/Developer/tools/scripts/migrate-project.sh

### Docker Shortcuts

    dcu    → docker compose up -d
    dcub   → docker compose up -d --build
    dcd    → docker compose down
    dcl    → docker compose logs -f
    dcp    → docker compose ps
    dce    → docker compose exec app

### Smart Laravel Docker (harus di folder project!)

    art <perintah>    → docker compose exec app php artisan <perintah>
    comp <perintah>   → docker compose exec app composer <perintah>

    Contoh:
    art migrate
    art make:model Post -mcr
    art route:list
    art cache:clear
    art tinker
    comp install
    comp require laravel/sanctum
    comp update

### Git Shortcuts (bawaan Oh My Zsh)

    gs      → git status
    ga      → git add .
    gaa     → git add --all
    gci     → git commit -m  (custom alias)
    gc      → git commit --verbose
    gcmsg   → git commit --message
    gp      → git push
    gpsup   → git push --set-upstream origin (current branch)
    gl      → git pull
    gf      → git fetch
    gfa     → git fetch --all --tags --prune
    gco     → git checkout
    gcb     → git checkout -b
    gcm     → git checkout main
    gcd     → git checkout develop
    gb      → git branch
    gba     → git branch --all
    gbd     → git branch --delete
    gm      → git merge
    gd      → git diff
    gds     → git diff --staged
    glog    → git log --oneline --graph
    glo     → git log --oneline --decorate
    glola   → git log --oneline --graph --all (dengan author & time)
    gst     → git stash
    gstp    → git stash pop
    gstl    → git stash list
    gstd    → git stash drop
    grh     → git reset
    grhh    → git reset --hard
    grhs    → git reset --soft
    grev    → git revert
    gcp     → git cherry-pick
    grb     → git rebase
    grbi    → git rebase --interactive

---

## Git Workflow

### Branch Strategy

    main          → production (jangan commit langsung!)
    develop       → development base
    feature/xxx   → fitur baru
    fix/xxx       → bug fix
    hotfix/xxx    → fix urgent production

### Daily Workflow

    # Mulai fitur baru
    gco develop && gl
    gcb feature/nama-fitur

    # Kerja & commit
    ga
    gci "feat: deskripsi fitur"

    # Selesai — merge ke develop
    gco develop
    gm feature/nama-fitur
    gbd feature/nama-fitur
    gp

### Conventional Commits

    feat      → fitur baru
    fix       → bug fix
    docs      → dokumentasi
    style     → formatting (bukan logic)
    refactor  → refactor kode
    test      → tambah/edit test
    chore     → maintenance, update dependency
    hotfix    → fix urgent production

    Contoh:
    gci "feat: add JWT authentication"
    gci "fix: resolve null pointer in CartController"
    gci "docs: update API documentation"
    gci "refactor: extract payment logic to service class"
    gci "chore: update composer dependencies"

---

## Git Cheatsheet Lengkap

    # ── Setup ────────────────────────────────────
    git config --global user.name "Nama"
    git config --global user.email "email"
    git config --global --list          # Lihat semua config

    # ── Basic ─────────────────────────────────────
    git init
    git clone git@github.com:user/repo.git
    git status
    git diff
    git diff --staged

    # ── Staging & Commit ──────────────────────────
    git add .
    git add <file>
    git reset HEAD <file>               # Unstage file
    git commit -m "feat: pesan"
    git commit --amend                  # Edit commit terakhir

    # ── Branch ────────────────────────────────────
    git branch
    git branch -a                       # Semua branch
    git checkout -b feature/login
    git checkout main
    git merge feature/login
    git branch -d feature/login
    git push origin --delete feature/login

    # ── Remote ────────────────────────────────────
    git remote -v
    git push origin main
    git push -u origin feature/login    # Push branch baru
    git pull
    git fetch

    # ── Stash ─────────────────────────────────────
    git stash                           # Simpan sementara
    git stash list
    git stash pop                       # Ambil kembali
    git stash drop

    # ── History ───────────────────────────────────
    git log --oneline
    git log --oneline --graph
    git log --author="NamaKamu"
    git show <commit-hash>
    git blame <file>                    # Siapa yang ubah baris ini

    # ── Undo ──────────────────────────────────────
    git checkout -- <file>             # Batalkan perubahan file
    git revert <commit-hash>           # Undo dengan commit baru (aman)
    git reset --soft HEAD~1            # Undo commit, keep changes staged
    git reset --hard HEAD~1            # Undo commit + hapus perubahan ⚠️

---

## Docker Cheatsheet Lengkap

    # ── docker compose ────────────────────────────
    dcu                                # up -d
    dcub                               # up -d --build
    dcd                                # down
    docker compose down -v             # down + hapus volumes ⚠️
    dcp                                # ps
    dcl                                # logs -f
    dce bash                           # exec app bash
    docker compose restart app         # restart container tertentu

    # ── Images ────────────────────────────────────
    docker images
    docker pull php:8.3-fpm
    docker rmi <image-id>
    docker image prune

    # ── Containers ────────────────────────────────
    docker ps
    docker ps -a                       # semua container
    docker stop <container>
    docker rm <container>

    # ── Cleanup ───────────────────────────────────
    docker system prune                # hapus semua yang tidak dipakai
    docker system prune -a             # hapus semua termasuk image ⚠️
    docker volume ls
    docker volume prune                # hapus volume tidak dipakai ⚠️

---

## macOS Shortcuts

    Cmd Space          → Spotlight Search
    Cmd Tab            → Switch aplikasi
    Cmd W              → Tutup window
    Cmd Q              → Quit aplikasi
    Cmd C / V / X      → Copy / Paste / Cut
    Cmd Z              → Undo
    Cmd Shift .        → Show/hide hidden files di Finder
    Cmd Shift 4        → Screenshot area
    Cmd Option Esc     → Force quit
    Ctrl C             → Stop proses di Terminal
    Ctrl L             → Clear terminal

---

## Editor Shortcuts

### Cursor

    Cmd K          → AI inline edit
    Cmd L          → AI chat sidebar
    Cmd Shift I    → AI Composer (edit banyak file)
    Tab            → Terima AI suggestion
    Esc            → Tolak AI suggestion
    Cmd P          → Quick file open
    Cmd Shift P    → Command palette
    Cmd backtick   → Toggle terminal
    Cmd B          → Toggle sidebar
    Cmd /          → Toggle comment
    Cmd D          → Select next occurrence
    Cmd Shift L    → Select all occurrences

### Google Antigravity

    Cmd I          → AI inline command
    Cmd L          → Toggle agent panel
    Cmd E          → Toggle editor ↔ agent manager view
    Tab            → Terima AI suggestion
    Esc            → Tolak AI suggestion
    Cmd P          → Quick file open
    Cmd Shift P    → Command palette
    Ctrl backtick  → Toggle terminal
    Cmd B          → Toggle sidebar
    Cmd /          → Toggle comment
    Cmd D          → Select next occurrence

---

## Homebrew Cheatsheet

    brew install <formula>          # Install package CLI
    brew install --cask <app>       # Install aplikasi GUI
    brew uninstall <formula>        # Hapus package
    brew update                     # Update Homebrew
    brew upgrade                    # Upgrade semua package
    brew upgrade <formula>          # Upgrade package tertentu
    brew list                       # Lihat semua yang terinstall
    brew list --cask                # Lihat semua app GUI
    brew info <formula>             # Info package
    brew search <keyword>           # Cari package
    brew doctor                     # Cek kesehatan Homebrew
    brew cleanup                    # Hapus versi lama
