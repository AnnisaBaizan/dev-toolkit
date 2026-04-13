#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

TEMPLATES="$HOME/Developer/tools/templates"
PROJECTS="$HOME/Developer/projects"

show_help() {
  echo -e "${BLUE}"
  echo "╔══════════════════════════════════════════════════════╗"
  echo "║             new-project — Help                       ║"
  echo "╚══════════════════════════════════════════════════════╝"
  echo -e "${NC}"
  echo -e "Buat project BARU dari nol."
  echo -e "Untuk project SUDAH ADA → pakai ${YELLOW}migrate-project${NC}"
  echo ""
  echo -e "${YELLOW}Usage:${NC}"
  echo -e "  ${GREEN}new-project <stack> <name>${NC}"
  echo ""
  echo -e "${YELLOW}Stacks:${NC}"
  echo "  laravel      → Laravel fresh install + Docker"
  echo "  codeigniter  → CodeIgniter fresh install + Docker"
  echo "  django       → Django fresh install + Docker"
  echo "  flask        → Flask fresh install + Docker"
  echo "  fastapi      → FastAPI fresh install + Docker"
  echo "  node         → Node.js + Express + Docker"
  echo "  golang       → Golang + Docker"
  echo "  react        → React + Vite"
  echo "  vue          → Vue 3 + Vite"
  echo "  nextjs       → Next.js"
  echo "  nuxtjs       → Nuxt.js"
  echo "  svelte       → SvelteKit"
  echo "  angular      → Angular"
  echo ""
  echo -e "${YELLOW}Examples:${NC}"
  echo "  new-project laravel blog"
  echo "  new-project react dashboard"
  echo "  new-project fastapi my-api"
  echo ""
  echo -e "${YELLOW}Other:${NC}"
  echo "  new-project list     → lihat semua project"
}

list_projects() {
  echo -e "${BLUE}📁 Your Projects:${NC}\n"
  echo -e "${YELLOW}── standalone ──${NC}"
  for lang in php python javascript golang; do
    items=$(ls "$PROJECTS/standalone/$lang" 2>/dev/null)
    [ -n "$items" ] && echo -e "  ${GREEN}$lang:${NC} $items"
  done
  echo -e "\n${YELLOW}── sandbox ──${NC}"
  for lang in php python javascript golang; do
    items=$(ls "$PROJECTS/sandbox/$lang" 2>/dev/null)
    [ -n "$items" ] && echo -e "  ${GREEN}$lang:${NC} $items"
  done
  echo -e "\n${YELLOW}── fullstack ──${NC}"
  items=$(ls "$PROJECTS/fullstack" 2>/dev/null)
  [ -n "$items" ] && echo "  $items" || echo "  (empty)"
}

# ── Copy docker files dari template ──────────
copy_docker_files() {
  local stack=$1
  local dest=$2
  local type=$3

  echo -e "\n${CYAN}📦 Copying Docker template...${NC}"

  case $stack in
    laravel|codeigniter)
      cp -r "$TEMPLATES/backend/$stack/docker" "$dest/"
      cp "$TEMPLATES/backend/$stack/docker-compose.yml" "$dest/"
      cp "$TEMPLATES/backend/$stack/.env.example" "$dest/"
      echo -e "${GREEN}  ✅ Docker files copied${NC}"
      ;;
    django|flask|fastapi|node|golang)
      cp -r "$TEMPLATES/backend/$stack/docker" "$dest/" 2>/dev/null || true
      cp "$TEMPLATES/backend/$stack/docker-compose.yml" "$dest/" 2>/dev/null || \
        echo -e "${YELLOW}  ⚠️  docker-compose.yml belum ada di template — lihat docs/04-stacks/${NC}"
      cp "$TEMPLATES/backend/$stack/.env.example" "$dest/" 2>/dev/null || true
      echo -e "${GREEN}  ✅ Docker files copied${NC}"
      ;;
    react|vue|nextjs|nuxtjs|svelte|angular)
      # Frontend tidak pakai Docker untuk dev
      echo -e "${CYAN}  Frontend stack — tidak pakai Docker untuk dev server${NC}"
      ;;
  esac
}

STACK=$1
NAME=$2

[ "$STACK" = "list" ] && list_projects && exit 0
[ -z "$STACK" ] || [ -z "$NAME" ] && show_help && exit 1

# Determine path
case $STACK in
  laravel|codeigniter)
    DEST="$PROJECTS/standalone/php/$NAME"
    LANG="php" ;;
  django|flask|fastapi)
    DEST="$PROJECTS/standalone/python/$NAME"
    LANG="python" ;;
  node)
    DEST="$PROJECTS/standalone/javascript/$NAME"
    LANG="javascript" ;;
  golang)
    DEST="$PROJECTS/standalone/golang/$NAME"
    LANG="golang" ;;
  react|vue|nextjs|nuxtjs|svelte|angular)
    DEST="$PROJECTS/standalone/javascript/$NAME"
    LANG="javascript" ;;
  *)
    echo -e "${RED}❌ Unknown stack: $STACK${NC}"
    show_help; exit 1 ;;
esac

# Cek destination
if [ -d "$DEST" ]; then
  echo -e "${RED}❌ Project sudah ada: $DEST${NC}"
  exit 1
fi

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║           Creating New Project                       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Stack : ${GREEN}$STACK${NC}"
echo -e "  Name  : ${GREEN}$NAME${NC}"
echo -e "  Path  : ${GREEN}$DEST${NC}"
echo ""

# Buat folder
mkdir -p "$DEST"

# Copy docker files dari template
copy_docker_files "$STACK" "$DEST" "$LANG"

# Setup .env
if [ -f "$DEST/.env.example" ]; then
  cp "$DEST/.env.example" "$DEST/.env"
  sed -i '' "s/PROJECT_NAME/$NAME/g" "$DEST/.env"
  echo -e "${GREEN}✅ .env created${NC}"
fi

# Stack-specific install
cd "$DEST"
case $STACK in
  laravel)
    echo -e "\n${CYAN}🐳 Starting Docker...${NC}"
    docker compose up -d --build
    sleep 10
    echo -e "\n${CYAN}📦 Installing Laravel...${NC}"
    docker compose exec -T app composer create-project laravel/laravel . --prefer-dist
    docker compose exec -T app php artisan key:generate
    docker compose exec -T app php artisan migrate
    PORT=$(grep NGINX_PORT .env | cut -d= -f2); PORT=${PORT:-8080}
    echo -e "\n${GREEN}✅ Laravel ready at http://localhost:$PORT${NC}"
    ;;
  codeigniter)
    echo -e "\n${CYAN}🐳 Starting Docker...${NC}"
    docker compose up -d --build
    sleep 10
    echo -e "\n${CYAN}📦 Installing CodeIgniter...${NC}"
    docker compose exec -T app composer create-project codeigniter4/appstarter . --prefer-dist
    PORT=$(grep NGINX_PORT .env | cut -d= -f2); PORT=${PORT:-8081}
    echo -e "\n${GREEN}✅ CodeIgniter ready at http://localhost:$PORT${NC}"
    ;;
  react)
    npm create vite@latest . -- --template react --yes
    npm install && npm install axios react-router-dom
    echo -e "\n${GREEN}✅ React ready — run: cd $DEST && npm run dev${NC}"
    ;;
  vue)
    npm create vite@latest . -- --template vue --yes
    npm install && npm install axios vue-router@4 pinia
    echo -e "\n${GREEN}✅ Vue ready — run: cd $DEST && npm run dev${NC}"
    ;;
  nextjs)
    npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --yes
    echo -e "\n${GREEN}✅ Next.js ready — run: cd $DEST && npm run dev${NC}"
    ;;
  *)
    echo -e "${YELLOW}⚠️  Template copied.${NC}"
    echo -e "Ikuti panduan: ~/Developer/tools/docs/04-stacks/$LANG.md"
    ;;
esac

# Buka di Antigravity
echo -e "\n${CYAN}🖥️  Opening in Antigravity...${NC}"
antigravity "$DEST"

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║        ✅ Project Created!                           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo -e "  📁 $DEST"
