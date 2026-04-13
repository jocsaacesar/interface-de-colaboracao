#!/usr/bin/env bash
# ==============================================================================
# Mnemosine — Script de instalação automatizada
# https://mnemosine.ia.br
#
# Uso:
#   curl -fsSL https://mnemosine.ia.br/instalar.sh | bash
#   ou
#   curl -fsSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/scripts/instalar.sh | bash
#
# O que este script faz:
#   1. Verifica (e instala se necessário) Node.js, npm, Git e Claude Code
#   2. Clona o repositório Mnemosine
#   3. Abre o Claude Code na pasta — o onboarding começa automaticamente
# ==============================================================================

set -euo pipefail

# --- Cores e formatação ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $1"; }
ok()      { echo -e "${GREEN}[ok]${NC} $1"; }
warn()    { echo -e "${YELLOW}[aviso]${NC} $1"; }
erro()    { echo -e "${RED}[erro]${NC} $1"; }

# --- Banner ---
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          Mnemosine — Instalação              ║${NC}"
echo -e "${BOLD}║      Sua IA com memória e identidade         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# --- Detectar OS ---
OS="$(uname -s)"
case "$OS" in
    Linux*)   PLATAFORMA="linux";;
    Darwin*)  PLATAFORMA="mac";;
    MINGW*|MSYS*|CYGWIN*) PLATAFORMA="windows";;
    *)        PLATAFORMA="desconhecido";;
esac
info "Sistema detectado: $PLATAFORMA"

# --- Funções de instalação ---

instalar_node() {
    info "Node.js não encontrado. Instalando..."

    if [ "$PLATAFORMA" = "mac" ]; then
        if command -v brew &>/dev/null; then
            info "Usando Homebrew..."
            brew install node
        else
            info "Homebrew não encontrado. Instalando nvm..."
            curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
            nvm install --lts
        fi
    elif [ "$PLATAFORMA" = "linux" ]; then
        info "Instalando via nvm..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
    elif [ "$PLATAFORMA" = "windows" ]; then
        erro "No Windows, baixe o Node.js manualmente em https://nodejs.org"
        erro "Depois rode este script novamente."
        exit 1
    fi
}

instalar_git() {
    info "Git não encontrado. Instalando..."

    if [ "$PLATAFORMA" = "mac" ]; then
        if command -v brew &>/dev/null; then
            brew install git
        else
            info "Instalando Xcode Command Line Tools (inclui Git)..."
            xcode-select --install 2>/dev/null || true
            echo ""
            warn "Uma janela pode ter aparecido pedindo para instalar."
            warn "Aceite, aguarde a instalação e rode este script novamente."
            exit 0
        fi
    elif [ "$PLATAFORMA" = "linux" ]; then
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm git
        else
            erro "Não consegui detectar o gerenciador de pacotes."
            erro "Instale o Git manualmente e rode este script novamente."
            exit 1
        fi
    elif [ "$PLATAFORMA" = "windows" ]; then
        erro "No Windows, baixe o Git em https://git-scm.com"
        erro "Depois rode este script novamente."
        exit 1
    fi
}

# --- Passo 1: Node.js ---
echo ""
info "Passo 1/4 — Verificando Node.js..."
if command -v node &>/dev/null; then
    NODE_V=$(node --version)
    ok "Node.js $NODE_V encontrado"
else
    instalar_node
    if command -v node &>/dev/null; then
        ok "Node.js $(node --version) instalado"
    else
        erro "Falha ao instalar Node.js. Instale manualmente em https://nodejs.org"
        exit 1
    fi
fi

# --- Passo 2: Git ---
info "Passo 2/4 — Verificando Git..."
if command -v git &>/dev/null; then
    GIT_V=$(git --version | awk '{print $3}')
    ok "Git $GIT_V encontrado"
else
    instalar_git
    if command -v git &>/dev/null; then
        ok "Git $(git --version | awk '{print $3}') instalado"
    else
        erro "Falha ao instalar Git. Instale manualmente em https://git-scm.com"
        exit 1
    fi
fi

# --- Passo 3: Claude Code ---
info "Passo 3/4 — Verificando Claude Code..."
if command -v claude &>/dev/null; then
    ok "Claude Code já instalado"
else
    info "Instalando Claude Code..."
    npm install -g @anthropic-ai/claude-code
    if command -v claude &>/dev/null; then
        ok "Claude Code instalado"
    else
        erro "Falha ao instalar Claude Code."
        erro "Tente manualmente: npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
fi

# --- Passo 4: Clonar e abrir ---
info "Passo 4/4 — Baixando Mnemosine..."

if [ -d "mnemosine" ]; then
    warn "Pasta 'mnemosine' já existe. Entrando nela..."
else
    git clone https://github.com/jocsaacesar/mnemosine.git
    ok "Repositório clonado"
fi

cd mnemosine

# --- Pronto ---
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║            Instalação completa!              ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Iniciando o Claude Code..."
echo -e "Diga ${BOLD}\"oi\"${NC} e o processo de configuração começa automaticamente."
echo ""

claude
