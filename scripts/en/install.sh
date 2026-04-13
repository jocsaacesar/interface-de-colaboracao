#!/usr/bin/env bash
# ==============================================================================
# Mnemosine — Automated installation script
# https://mnemosine.ia.br
#
# Usage:
#   curl -fsSL https://mnemosine.ia.br/en/install.sh | bash
#   or
#   curl -fsSL https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/scripts/en/install.sh | bash
#
# What this script does:
#   1. Checks (and installs if needed) Node.js, npm, Git and Claude Code
#   2. Clones the Mnemosine repository
#   3. Opens Claude Code in the folder — onboarding starts automatically
# ==============================================================================

set -euo pipefail

# --- Colors and formatting ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[info]${NC} $1"; }
ok()      { echo -e "${GREEN}[ok]${NC} $1"; }
warn()    { echo -e "${YELLOW}[warn]${NC} $1"; }
erro()    { echo -e "${RED}[error]${NC} $1"; }

# --- Banner ---
echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║          Mnemosine — Installation            ║${NC}"
echo -e "${BOLD}║   Collaboration Interface for Claude Code    ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""

# --- Detect OS ---
OS="$(uname -s)"
case "$OS" in
    Linux*)   PLATFORM="linux";;
    Darwin*)  PLATFORM="mac";;
    MINGW*|MSYS*|CYGWIN*) PLATFORM="windows";;
    *)        PLATFORM="unknown";;
esac
info "Detected system: $PLATFORM"

# --- Installation functions ---

install_node() {
    info "Node.js not found. Installing..."

    if [ "$PLATFORM" = "mac" ]; then
        if command -v brew &>/dev/null; then
            info "Using Homebrew..."
            brew install node
        else
            info "Homebrew not found. Installing nvm..."
            curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
            nvm install --lts
        fi
    elif [ "$PLATFORM" = "linux" ]; then
        info "Installing via nvm..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
        nvm install --lts
    elif [ "$PLATFORM" = "windows" ]; then
        erro "On Windows, download Node.js manually from https://nodejs.org"
        erro "Then run this script again."
        exit 1
    fi
}

install_git() {
    info "Git not found. Installing..."

    if [ "$PLATFORM" = "mac" ]; then
        if command -v brew &>/dev/null; then
            brew install git
        else
            info "Installing Xcode Command Line Tools (includes Git)..."
            xcode-select --install 2>/dev/null || true
            echo ""
            warn "A dialog may have appeared asking you to install."
            warn "Accept it, wait for the installation, and run this script again."
            exit 0
        fi
    elif [ "$PLATFORM" = "linux" ]; then
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm git
        else
            erro "Could not detect package manager."
            erro "Install Git manually and run this script again."
            exit 1
        fi
    elif [ "$PLATFORM" = "windows" ]; then
        erro "On Windows, download Git from https://git-scm.com"
        erro "Then run this script again."
        exit 1
    fi
}

# --- Step 1: Node.js ---
echo ""
info "Step 1/4 — Checking Node.js..."
if command -v node &>/dev/null; then
    NODE_V=$(node --version)
    ok "Node.js $NODE_V found"
else
    install_node
    if command -v node &>/dev/null; then
        ok "Node.js $(node --version) installed"
    else
        erro "Failed to install Node.js. Install manually from https://nodejs.org"
        exit 1
    fi
fi

# --- Step 2: Git ---
info "Step 2/4 — Checking Git..."
if command -v git &>/dev/null; then
    GIT_V=$(git --version | awk '{print $3}')
    ok "Git $GIT_V found"
else
    install_git
    if command -v git &>/dev/null; then
        ok "Git $(git --version | awk '{print $3}') installed"
    else
        erro "Failed to install Git. Install manually from https://git-scm.com"
        exit 1
    fi
fi

# --- Step 3: Claude Code ---
info "Step 3/4 — Checking Claude Code..."
if command -v claude &>/dev/null; then
    ok "Claude Code already installed"
else
    info "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
    if command -v claude &>/dev/null; then
        ok "Claude Code installed"
    else
        erro "Failed to install Claude Code."
        erro "Try manually: npm install -g @anthropic-ai/claude-code"
        exit 1
    fi
fi

# --- Step 4: Clone and open ---
info "Step 4/4 — Downloading Mnemosine..."

if [ -d "mnemosine" ]; then
    warn "'mnemosine' folder already exists. Entering it..."
else
    git clone https://github.com/jocsaacesar/mnemosine.git
    ok "Repository cloned"
fi

cd mnemosine

# --- Done ---
echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║          Installation complete!              ║${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Starting Claude Code..."
echo -e "Say ${BOLD}\"hi\"${NC} and the setup process starts automatically."
echo ""

claude
