# 🛠️ Developer Environment
> MacBook Air M1 · macOS Tahoe 26.4 · Docker-based Development

---

## 📚 Documentation Index

| File | Isi |
|---|---|
| [01-environment.md](01-environment.md) | Setup Mac dari awal (Homebrew, Git, SSH, Oh My Zsh, tools) |
| [02-docker.md](02-docker.md) | Konsep Docker, perintah, troubleshooting |
| [03-templates.md](03-templates.md) | Script migrate-project & new-project |
| [04-stacks/php.md](04-stacks/php.md) | Laravel & CodeIgniter |
| [04-stacks/python.md](04-stacks/python.md) | Django, Flask, FastAPI |
| [04-stacks/javascript.md](04-stacks/javascript.md) | React, Vue, Next.js, Nuxt.js, Svelte, Angular, Node.js |
| [04-stacks/golang.md](04-stacks/golang.md) | Golang |
| [05-fullstack.md](05-fullstack.md) | Gabungkan frontend + backend, CORS, API connection |
| [06-ai-tools.md](06-ai-tools.md) | Claude Code CLI, Cursor, agent_config workflows |
| [07-reference.md](07-reference.md) | Ports, aliases, cheatsheet semua perintah |

---

## 🗂️ Folder Structure
```
~/Developer/
├── projects/
│   ├── standalone/        # Project satu stack
│   │   ├── php/           # Laravel, CodeIgniter
│   │   ├── python/        # Django, Flask, FastAPI
│   │   ├── javascript/    # React, Vue, Node.js, dll
│   │   └── golang/        # Golang
│   ├── sandbox/           # Belajar & experiment
│   │   ├── php/
│   │   ├── python/
│   │   ├── javascript/
│   │   └── golang/
│   └── fullstack/         # Project frontend + backend
├── tools/
│   ├── agent_config/      # AI SOP & workflows → 06-ai-tools.md
│   ├── templates/         # Project templates → 03-templates.md
│   │   ├── backend/       # laravel, codeigniter, django, flask, fastapi, node, golang
│   │   ├── frontend/      # react, vue, nextjs, nuxtjs, svelte, angular
│   │   └── fullstack/     # laravel-react, laravel-vue, fastapi-react, dll
│   ├── scripts/           # migrate-project.sh, new-project.sh
│   └── docs/              # File dokumentasi ini
```

---

## ⚡ Quick Reference
```bash
# ── Project Management ────────────────────
migrate-project clone laravel git@github.com:user/repo.git
migrate-project clone codeigniter git@github.com:user/repo.git
migrate-project local laravel ~/path/to/project
new-project laravel nama-project
new-project list

# ── Daily Laravel (di dalam folder project) ──
dcu              # docker compose up -d
dcd              # docker compose down
dcl              # docker compose logs -f
art migrate      # php artisan migrate
art make:model   # php artisan make:model
comp install     # composer install

# ── Git ───────────────────────────────────
gs               # git status
ga               # git add .
gci "feat: ..."  # git commit -m
gp               # git push
gl               # git pull
glog             # git log --oneline --graph

# ── Navigation ────────────────────────────
dev              # cd ~/Developer
projects         # cd ~/Developer/projects
tools            # cd ~/Developer/tools
docs             # cd ~/Developer/tools/docs

# ── AI Tools ──────────────────────────────
claude           # Buka Claude Code CLI
cursor .         # Buka project di Cursor
```

---

## 🔧 Tools Installed

| Tool | Versi | Fungsi |
|---|---|---|
| macOS Tahoe | 26.4 | Operating System |
| Homebrew | 5.1.2 | Package manager |
| Git | 2.50.1 | Version control |
| Docker Desktop | 29.3.1 | Container runtime |
| Node.js | 24.14.1 | JavaScript runtime |
| nvm | 0.40.4 | Node version manager |
| Claude Code | 2.1.86 | AI coding assistant CLI |
| Cursor | 2.6.22 | AI-powered code editor |
| TablePlus | 6.8.6 | Database GUI |
| Oh My Zsh | latest | Terminal enhancement |

> PHP & Composer tidak diinstall lokal — semua via Docker.
> Gunakan alias `art` dan `comp` sebagai shortcut.

---

## 🚀 Daily Workflow
```bash
# 1. Masuk folder project
cd ~/Developer/projects/standalone/php/nama-project

# 2. Start Docker
dcu

# 3. Buka editor
cursor .

# 4. Coding dengan AI
claude   # Claude Code CLI untuk analisis & debug

# 5. Selesai
dcd
```
