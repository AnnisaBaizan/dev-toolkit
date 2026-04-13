# 🖥️ Environment Setup — Mac dari Awal
> Referensi: README.md untuk overview | 02-docker.md untuk Docker setup

---

## 1. Homebrew

Package manager untuk macOS — fondasi semua instalasi.

    # Install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # M1 — tambah ke PATH
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    source ~/.zshrc
    
    # Verifikasi
    brew --version    # Homebrew 5.1.2
    brew update && brew upgrade
    brew doctor

---

## 2. Git Config

    git config --global user.name "Nama Kamu"
    git config --global user.email "email@kamu.com"
    git config --global core.editor nano
    git config --global commit.template ~/.gitmessage
    git config --global core.excludesfile ~/.gitignore_global
    
    # Verifikasi
    git config --global --list

### Git Commit Template

    cat > ~/.gitmessage
    # <type>: <deskripsi singkat> (max 50 karakter)
    # feat     → fitur baru
    # fix      → bug fix
    # docs     → dokumentasi
    # style    → formatting
    # refactor → refactor kode
    # test     → tambah test
    # chore    → maintenance
    # hotfix   → fix urgent production

### Global .gitignore

    cat > ~/.gitignore_global
    .DS_Store
    .DS_Store?
    ._*
    .env
    .env.local
    .env.*.local
    .cursor/
    .vscode/
    *.log
    docker-compose.override.yml
    
    git config --global core.excludesfile ~/.gitignore_global

---

## 3. SSH Key untuk GitHub

SSH Key = kartu akses otomatis ke GitHub tanpa ketik password.

    # Buat SSH key
    ssh-keygen -t ed25519 -C "email@kamu.com"
    # Tekan Enter 3x
    
    # Tambah ke SSH agent
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519
    
    # Tampilkan public key
    cat ~/.ssh/id_ed25519.pub

Daftarkan ke GitHub:
1. github.com → Settings → SSH and GPG keys → New SSH key
2. Title: MacBook Air M1
3. Key type: Authentication Key
4. Paste public key → Add SSH key

    # Test koneksi
    ssh -T git@github.com
    # Hi username! You've successfully authenticated...

---

## 4. Oh My Zsh

Terminal enhancement — autocomplete, syntax highlighting, ratusan alias Git otomatis.

    # Install
    sh -c "$(curl -fsSL https://install.ohmyz.sh)"
    
    # Install plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # Di ~/.zshrc — cari plugins=(git) ubah menjadi:
    plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
    
    source ~/.zshrc

---

## 5. Node.js via nvm

nvm = Node Version Manager — manage banyak versi Node.js tanpa konflik.

    brew install nvm
    mkdir ~/.nvm
    
    # Tambah ke ~/.zshrc
    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
    
    source ~/.zshrc
    
    nvm install --lts
    nvm alias default node
    
    node --version    # v24.14.1
    npm --version     # 11.11.0

---

## 6. Docker Desktop

Lihat 02-docker.md untuk instalasi dan konsep lengkap.

    brew install --cask docker
    open /Applications/Docker.app
    
    docker --version           # Docker version 29.3.1
    docker compose version     # Docker Compose version v5.1.0
    docker run hello-world

---

## 7. Claude Code CLI

AI assistant di Terminal — bisa baca dan analisis seluruh project.

    curl -fsSL https://claude.ai/install.sh | bash
    claude login
    claude --version    # 2.1.86
    claude whoami

Lihat 06-ai-tools.md untuk cara penggunaan lengkap.

---

## 8. Code Editor (Cursor atau Antigravity)

Pilih salah satu — keduanya berbasis VS Code dengan AI built-in.

### Opsi A: Cursor

VS Code fork dengan AI built-in — Claude Pro terintegrasi via extension.

    brew install --cask cursor
    cursor .    # Buka folder aktif di Cursor

Setup setelah install:
1. Login dengan akun GitHub
2. Install extension: Claude Code for VS Code (by Anthropic)
3. Login Claude di extension

Shortcuts penting:
- Cmd K         → AI inline edit
- Cmd L         → AI chat sidebar
- Cmd Shift I   → AI Composer (edit banyak file)
- Tab           → Terima AI suggestion

### Opsi B: Google Antigravity

Agent-first IDE dari Google — AI model Gemini + Claude tersedia built-in, gratis.

    # Download dari: antigravity.google
    # Atau via terminal (jika CLI tersedia setelah install):
    antigravity .    # Buka folder aktif

Setup setelah install:
1. Login dengan akun Google
2. Pilih AI model (Gemini 3.1 Pro, Claude Sonnet/Opus, atau GPT-OSS-120B)
3. Claude Code extension (by Anthropic) juga bisa diinstall karena berbasis VS Code

Shortcuts penting:
- Cmd I         → AI inline command
- Cmd L         → Toggle agent panel
- Cmd E         → Toggle editor ↔ agent manager view
- Tab           → Terima AI suggestion

CATATAN: Antigravity punya 2 tampilan — Editor view (seperti VS Code biasa) dan
Manager view (orkestrasi banyak agent AI sekaligus secara paralel).

Lihat 06-ai-tools.md untuk workflow lengkap.

---

## 9. TablePlus (Database GUI)

Visual manager untuk semua database — MySQL, PostgreSQL, SQLite, Redis, MongoDB.

    brew install --cask tableplus
    open /Applications/TablePlus.app

Setup koneksi MySQL (untuk Laravel):
- Name     : MySQL Local
- Host     : 127.0.0.1
- Port     : 3306
- User     : root
- Password : secret
- Database : (kosongkan — supaya lihat semua DB)

PENTING: Pastikan container Docker sedang jalan sebelum connect!
Lihat 07-reference.md untuk daftar port semua database.

---

## 10. Aliases & Shell Functions

Semua shortcut tersimpan di ~/.zshrc

### Smart Laravel Docker Shortcuts

Tambah ke ~/.zshrc:

    art() {
      if [ -f "docker-compose.yml" ]; then
        docker compose exec app php artisan "$@"
      else
        echo "Tidak ada docker-compose.yml di folder ini!"
        echo "cd ke folder project dulu, lalu docker compose up -d"
      fi
    }
    
    comp() {
      if [ -f "docker-compose.yml" ]; then
        docker compose exec app composer "$@"
      else
        echo "Tidak ada docker-compose.yml di folder ini!"
        echo "cd ke folder project dulu, lalu docker compose up -d"
      fi
    }

Cara pakai:

    cd ~/Developer/projects/standalone/php/nama-project
    dcu              # start Docker dulu
    art migrate      # php artisan migrate
    art make:model   # php artisan make:model
    comp install     # composer install
    comp require laravel/sanctum

### Edit & Reload .zshrc

    nano ~/.zshrc      # Edit
    source ~/.zshrc    # Terapkan perubahan
    alias              # Lihat semua alias aktif

Lihat 07-reference.md untuk daftar lengkap semua alias.
