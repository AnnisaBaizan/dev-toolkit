#!/bin/bash

# ============================================
# migrate-project.sh
# Migrate existing project → add Docker → run
#
# Usage:
#   migrate-project clone <stack> <git-url>
#   migrate-project local <stack> <path>
# ============================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TEMPLATES="$HOME/Developer/tools/templates"
PROJECTS="$HOME/Developer/projects"

# ── Help ────────────────────────────────────
show_help() {
  echo -e "${BLUE}"
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║           migrate-project — Help                     ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "Migrate existing project → add Docker → run"
  echo ""
  echo -e "${YELLOW}Usage:${NC}"
  echo -e "  ${GREEN}migrate-project clone <stack> <git-url>${NC}"
  echo -e "  ${GREEN}migrate-project local <stack> <path>${NC}"
  echo ""
  echo -e "${YELLOW}Stacks:${NC}"
  echo "  laravel      → Laravel monolith + Blade + MySQL + Redis"
  echo "  codeigniter  → CodeIgniter + MySQL + Redis"
  echo "  fastapi-react → FastAPI (Python) + React (frontend)"
  echo ""
  echo -e "${YELLOW}Examples:${NC}"
  echo "  migrate-project clone laravel git@github.com:user/repo.git"
  echo "  migrate-project clone codeigniter git@github.com:user/repo.git"
  echo "  migrate-project clone fastapi-react git@github.com:user/backend.git"
  echo ""
  echo "  migrate-project local laravel ~/Downloads/my-old-project"
  echo "  migrate-project local codeigniter ~/Desktop/ci-project"
}

# ── Detect project name from git url or path ─
get_project_name() {
  local source=$1
  # Ambil nama dari akhir URL/path, hapus .git
  basename "$source" .git
}

# ── Determine destination path ───────────────
get_dest_path() {
  local stack=$1
  local name=$2
  case $stack in
    laravel|codeigniter) echo "$PROJECTS/standalone/php/$name" ;;
    fastapi-react)       echo "$PROJECTS/fullstack/$name" ;;
    *)                   echo "$PROJECTS/standalone/php/$name" ;;
  esac
}

# ── Copy docker template ─────────────────────
copy_docker_files() {
  local stack=$1
  local dest=$2

  echo -e "${CYAN}📦 Copying Docker template for: $stack${NC}"

  case $stack in
    laravel)
      cp -r "$TEMPLATES/backend/laravel/docker" "$dest/"
      cp "$TEMPLATES/backend/laravel/docker-compose.yml" "$dest/"
      echo -e "${GREEN}  ✅ Docker files copied (Laravel)${NC}"
      ;;
    codeigniter)
      cp -r "$TEMPLATES/backend/codeigniter/docker" "$dest/"
      cp "$TEMPLATES/backend/codeigniter/docker-compose.yml" "$dest/"
      echo -e "${GREEN}  ✅ Docker files copied (CodeIgniter)${NC}"
      ;;
    fastapi-react)
      # Backend
      cp -r "$TEMPLATES/backend/fastapi/docker" "$dest/backend/"
      cp "$TEMPLATES/backend/fastapi/docker-compose.yml" "$dest/backend/"
      # Frontend
      cp "$TEMPLATES/frontend/react/docker-compose.yml" "$dest/frontend/" 2>/dev/null || true
      echo -e "${GREEN}  ✅ Docker files copied (FastAPI + React)${NC}"
      ;;
  esac
}

# ── Setup .env ───────────────────────────────
setup_env() {
  local dest=$1
  local name=$2

  if [ -f "$dest/.env.example" ] && [ ! -f "$dest/.env" ]; then
    cp "$dest/.env.example" "$dest/.env"
    # Replace placeholder dengan nama project
    sed -i '' "s/PROJECT_NAME/$name/g" "$dest/.env"
    echo -e "${GREEN}  ✅ .env created from .env.example${NC}"
    echo -e "${YELLOW}  ⚠️  Cek dan sesuaikan .env sebelum lanjut!${NC}"
  elif [ -f "$dest/.env" ]; then
    echo -e "${YELLOW}  ⚠️  .env sudah ada — tidak ditimpa${NC}"
    echo -e "  Pastikan DB_HOST=db (bukan localhost!)"
  else
    echo -e "${YELLOW}  ⚠️  .env.example tidak ditemukan${NC}"
    echo -e "  Buat .env manual — lihat docs/04-stacks/php.md"
  fi
}

# ── Fix .env for Docker ──────────────────────
fix_env_for_docker() {
  local dest=$1
  local name=$2

  if [ -f "$dest/.env" ]; then
    # Pastikan DB_HOST pakai nama container bukan localhost
    sed -i '' 's/DB_HOST=127.0.0.1/DB_HOST=db/g' "$dest/.env"
    sed -i '' 's/DB_HOST=localhost/DB_HOST=db/g' "$dest/.env"
    # Pastikan Redis pakai nama container
    sed -i '' 's/REDIS_HOST=127.0.0.1/REDIS_HOST=redis/g' "$dest/.env"
    sed -i '' 's/REDIS_HOST=localhost/REDIS_HOST=redis/g' "$dest/.env"
    echo -e "${GREEN}  ✅ .env fixed for Docker (DB_HOST=db, REDIS_HOST=redis)${NC}"
  fi
}

# ── Laravel post-setup ───────────────────────
laravel_setup() {
  local dest=$1
  local name=$2

  cd "$dest"

  echo -e "\n${CYAN}🐳 Starting Docker containers...${NC}"
  docker compose up -d --build

  echo -e "\n${CYAN}⏳ Waiting for database to be ready...${NC}"
  sleep 10

  echo -e "\n${CYAN}📦 Installing Composer dependencies...${NC}"
  docker compose exec -T app composer install --no-interaction

  echo -e "\n${CYAN}🔑 Generating app key...${NC}"
  docker compose exec -T app php artisan key:generate --force

  echo -e "\n${CYAN}🗄️  Running migrations...${NC}"
  docker compose exec -T app php artisan migrate --force

  echo -e "\n${CYAN}🔧 Setting permissions...${NC}"
  docker compose exec -T app chmod -R 775 storage bootstrap/cache
  docker compose exec -T app chown -R www-data:www-data storage bootstrap/cache

  # Cek apakah ada seeder
  if [ -f "$dest/database/seeders/DatabaseSeeder.php" ]; then
    echo -e "\n${YELLOW}❓ Jalankan seeder? (y/n)${NC}"
    read -r run_seeder
    if [ "$run_seeder" = "y" ]; then
      docker compose exec -T app php artisan db:seed
      echo -e "${GREEN}  ✅ Seeder dijalankan${NC}"
    fi
  fi

  # Port yang dipakai
  PORT=$(grep NGINX_PORT "$dest/.env" 2>/dev/null | cut -d= -f2)
  PORT=${PORT:-8080}
  echo -e "\n${GREEN}✅ Laravel ready at http://localhost:$PORT${NC}"
}

# ── CodeIgniter post-setup ───────────────────
codeigniter_setup() {
  local dest=$1

  cd "$dest"

  echo -e "\n${CYAN}🐳 Starting Docker containers...${NC}"
  docker compose up -d --build

  echo -e "\n${CYAN}⏳ Waiting for database...${NC}"
  sleep 10

  echo -e "\n${CYAN}📦 Installing Composer dependencies...${NC}"
  docker compose exec -T app composer install --no-interaction

  echo -e "\n${CYAN}🗄️  Running migrations...${NC}"
  docker compose exec -T app php spark migrate --all 2>/dev/null || \
  echo -e "${YELLOW}  ⚠️  Spark migrate gagal — jalankan manual: docker compose exec app php spark migrate${NC}"

  PORT=$(grep NGINX_PORT "$dest/.env" 2>/dev/null | cut -d= -f2)
  PORT=${PORT:-8081}
  echo -e "\n${GREEN}✅ CodeIgniter ready at http://localhost:$PORT${NC}"
}

# ── FastAPI + React post-setup ───────────────
fastapi_react_setup() {
  local dest=$1

  echo -e "\n${CYAN}🐳 Starting FastAPI backend...${NC}"
  cd "$dest/backend"
  docker compose up -d --build

  echo -e "\n${CYAN}📦 Installing React dependencies...${NC}"
  cd "$dest/frontend"
  npm install

  echo -e "\n${GREEN}✅ FastAPI ready at http://localhost:8000${NC}"
  echo -e "${GREEN}✅ React — jalankan: cd $dest/frontend && npm run dev${NC}"
}

# ══════════════════════════════════════════════
# MAIN
# ══════════════════════════════════════════════

MODE=$1
STACK=$2
SOURCE=$3

if [ -z "$MODE" ] || [ -z "$STACK" ] || [ -z "$SOURCE" ]; then
  show_help
  exit 1
fi

# Validasi stack
case $STACK in
  laravel|codeigniter|fastapi-react) ;;
  *)
    echo -e "${RED}❌ Unknown stack: $STACK${NC}"
    echo -e "Supported: laravel, codeigniter, fastapi-react"
    exit 1
    ;;
esac

# Ambil nama project
PROJECT_NAME=$(get_project_name "$SOURCE")
DEST=$(get_dest_path "$STACK" "$PROJECT_NAME")

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║           Migrating Project to Mac                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Mode    : ${GREEN}$MODE${NC}"
echo -e "  Stack   : ${GREEN}$STACK${NC}"
echo -e "  Source  : ${GREEN}$SOURCE${NC}"
echo -e "  Name    : ${GREEN}$PROJECT_NAME${NC}"
echo -e "  Dest    : ${GREEN}$DEST${NC}"
echo ""

# Cek destination sudah ada
if [ -d "$DEST" ]; then
  echo -e "${RED}❌ Folder sudah ada: $DEST${NC}"
  echo -e "Hapus dulu atau gunakan nama berbeda."
  exit 1
fi

# ── MODE: clone ──────────────────────────────
if [ "$MODE" = "clone" ]; then
  echo -e "${CYAN}📥 Cloning from GitHub...${NC}"

  # Untuk fastapi-react, clone ke subfolder backend
  if [ "$STACK" = "fastapi-react" ]; then
    mkdir -p "$DEST/frontend"
    git clone "$SOURCE" "$DEST/backend"
  else
    git clone "$SOURCE" "$DEST"
  fi

  if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Git clone gagal! Cek URL dan SSH key kamu.${NC}"
    exit 1
  fi
  echo -e "${GREEN}  ✅ Clone berhasil${NC}"

# ── MODE: local ──────────────────────────────
elif [ "$MODE" = "local" ]; then
  echo -e "${CYAN}📁 Copying local project...${NC}"

  if [ ! -d "$SOURCE" ]; then
    echo -e "${RED}❌ Folder tidak ditemukan: $SOURCE${NC}"
    exit 1
  fi

  if [ "$STACK" = "fastapi-react" ]; then
    mkdir -p "$DEST/frontend"
    cp -r "$SOURCE" "$DEST/backend"
  else
    cp -r "$SOURCE" "$DEST"
  fi
  echo -e "${GREEN}  ✅ Project copied${NC}"

else
  echo -e "${RED}❌ Unknown mode: $MODE${NC}"
  show_help
  exit 1
fi

# ── Copy Docker files ────────────────────────
copy_docker_files "$STACK" "$DEST"

# ── Setup .env ───────────────────────────────
echo -e "\n${CYAN}⚙️  Setting up environment...${NC}"
if [ "$STACK" = "fastapi-react" ]; then
  setup_env "$DEST/backend" "$PROJECT_NAME"
  fix_env_for_docker "$DEST/backend" "$PROJECT_NAME"
else
  setup_env "$DEST" "$PROJECT_NAME"
  fix_env_for_docker "$DEST" "$PROJECT_NAME"
fi

# ── Pause — beri kesempatan cek .env ─────────
echo ""
echo -e "${YELLOW}══════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Buka .env dan sesuaikan konfigurasi!${NC}"
echo -e "${YELLOW}══════════════════════════════════════════${NC}"
echo -e "  Tekan ${GREEN}Enter${NC} kalau sudah siap lanjut..."
read -r

# ── Run post-setup per stack ─────────────────
case $STACK in
  laravel)      laravel_setup "$DEST" "$PROJECT_NAME" ;;
  codeigniter)  codeigniter_setup "$DEST" ;;
  fastapi-react) fastapi_react_setup "$DEST" ;;
esac

# ── Open in Cursor ───────────────────────────
echo -e "\n${CYAN}🖥️  Opening in Cursor...${NC}"
cursor "$DEST"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✅ Migration Complete!                        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  📁 Location : $DEST"
echo -e "  📖 Docs     : ~/Developer/tools/docs/04-stacks/php.md"
