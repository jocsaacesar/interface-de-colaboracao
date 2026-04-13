# ==============================================================================
# Mnemosine — Script de instalação automatizada (Windows PowerShell)
# https://mnemosine.ia.br
#
# Uso:
#   irm https://mnemosine.ia.br/instalar.ps1 | iex
#   ou
#   irm https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/scripts/instalar.ps1 | iex
#
# O que este script faz:
#   1. Verifica (e instala se necessário) Node.js, Git e Claude Code
#   2. Clona o repositório Mnemosine
#   3. Abre o Claude Code na pasta — o onboarding começa automaticamente
# ==============================================================================

$ErrorActionPreference = "Stop"

# --- Funções de output ---
function Write-Info  { param($msg) Write-Host "[info] " -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-Ok    { param($msg) Write-Host "[ok] " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn  { param($msg) Write-Host "[aviso] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Erro  { param($msg) Write-Host "[erro] " -ForegroundColor Red -NoNewline; Write-Host $msg }

# --- Banner ---
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "         Mnemosine  -  Instalacao              " -ForegroundColor Cyan
Write-Host "  Interface de Colaboracao com Claude Code     " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- Verificar se winget existe ---
$temWinget = Get-Command winget -ErrorAction SilentlyContinue

# --- Passo 1: Node.js ---
Write-Host ""
Write-Info "Passo 1/4 - Verificando Node.js..."
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeV = & node --version
    Write-Ok "Node.js $nodeV encontrado"
} else {
    Write-Info "Node.js nao encontrado. Instalando..."
    if ($temWinget) {
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        # Atualizar PATH na sessão atual
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeCmd) {
            Write-Ok "Node.js $(node --version) instalado"
        } else {
            Write-Erro "Falha ao instalar Node.js."
            Write-Erro "Baixe manualmente em https://nodejs.org e rode este script novamente."
            exit 1
        }
    } else {
        Write-Erro "winget nao disponivel. Baixe o Node.js manualmente em https://nodejs.org"
        Write-Erro "Depois rode este script novamente."
        exit 1
    }
}

# --- Passo 2: Git ---
Write-Info "Passo 2/4 - Verificando Git..."
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitV = (& git --version) -replace "git version ", ""
    Write-Ok "Git $gitV encontrado"
} else {
    Write-Info "Git nao encontrado. Instalando..."
    if ($temWinget) {
        winget install Git.Git --accept-source-agreements --accept-package-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $gitCmd = Get-Command git -ErrorAction SilentlyContinue
        if ($gitCmd) {
            Write-Ok "Git instalado"
        } else {
            Write-Erro "Falha ao instalar Git."
            Write-Erro "Baixe manualmente em https://git-scm.com e rode este script novamente."
            exit 1
        }
    } else {
        Write-Erro "winget nao disponivel. Baixe o Git manualmente em https://git-scm.com"
        Write-Erro "Depois rode este script novamente."
        exit 1
    }
}

# --- Passo 3: Claude Code ---
Write-Info "Passo 3/4 - Verificando Claude Code..."
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    Write-Ok "Claude Code ja instalado"
} else {
    Write-Info "Instalando Claude Code..."
    & npm install -g @anthropic-ai/claude-code
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
    if ($claudeCmd) {
        Write-Ok "Claude Code instalado"
    } else {
        Write-Erro "Falha ao instalar Claude Code."
        Write-Erro "Tente manualmente: npm install -g @anthropic-ai/claude-code"
        exit 1
    }
}

# --- Passo 4: Clonar e abrir ---
Write-Info "Passo 4/4 - Baixando Mnemosine..."

if (Test-Path "mnemosine") {
    Write-Warn "Pasta 'mnemosine' ja existe. Entrando nela..."
} else {
    & git clone https://github.com/jocsaacesar/mnemosine.git
    Write-Ok "Repositorio clonado"
}

Set-Location mnemosine

# --- Pronto ---
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "           Instalacao completa!                " -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Iniciando o Claude Code..."
Write-Host 'Diga "oi" e o processo de configuracao comeca automaticamente.' -ForegroundColor White
Write-Host ""

& claude
