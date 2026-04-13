# ==============================================================================
# Mnemosine — Automated installation script (Windows PowerShell)
# https://mnemosine.ia.br
#
# Usage:
#   irm https://mnemosine.ia.br/en/install.ps1 | iex
#   or
#   irm https://raw.githubusercontent.com/jocsaacesar/mnemosine/main/scripts/en/install.ps1 | iex
#
# What this script does:
#   1. Checks (and installs if needed) Node.js, Git and Claude Code
#   2. Clones the Mnemosine repository
#   3. Opens Claude Code in the folder — onboarding starts automatically
# ==============================================================================

$ErrorActionPreference = "Stop"

# --- Output functions ---
function Write-Info  { param($msg) Write-Host "[info] " -ForegroundColor Blue -NoNewline; Write-Host $msg }
function Write-Ok    { param($msg) Write-Host "[ok] " -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn  { param($msg) Write-Host "[warn] " -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Erro  { param($msg) Write-Host "[error] " -ForegroundColor Red -NoNewline; Write-Host $msg }

# --- Banner ---
Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "        Mnemosine  -  Installation             " -ForegroundColor Cyan
Write-Host " Collaboration Interface for Claude Code       " -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- Check if winget exists ---
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue

# --- Step 1: Node.js ---
Write-Host ""
Write-Info "Step 1/4 - Checking Node.js..."
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeV = & node --version
    Write-Ok "Node.js $nodeV found"
} else {
    Write-Info "Node.js not found. Installing..."
    if ($hasWinget) {
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeCmd) {
            Write-Ok "Node.js $(node --version) installed"
        } else {
            Write-Erro "Failed to install Node.js."
            Write-Erro "Download manually from https://nodejs.org and run this script again."
            exit 1
        }
    } else {
        Write-Erro "winget not available. Download Node.js manually from https://nodejs.org"
        Write-Erro "Then run this script again."
        exit 1
    }
}

# --- Step 2: Git ---
Write-Info "Step 2/4 - Checking Git..."
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitV = (& git --version) -replace "git version ", ""
    Write-Ok "Git $gitV found"
} else {
    Write-Info "Git not found. Installing..."
    if ($hasWinget) {
        winget install Git.Git --accept-source-agreements --accept-package-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $gitCmd = Get-Command git -ErrorAction SilentlyContinue
        if ($gitCmd) {
            Write-Ok "Git installed"
        } else {
            Write-Erro "Failed to install Git."
            Write-Erro "Download manually from https://git-scm.com and run this script again."
            exit 1
        }
    } else {
        Write-Erro "winget not available. Download Git manually from https://git-scm.com"
        Write-Erro "Then run this script again."
        exit 1
    }
}

# --- Step 3: Claude Code ---
Write-Info "Step 3/4 - Checking Claude Code..."
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    Write-Ok "Claude Code already installed"
} else {
    Write-Info "Installing Claude Code..."
    & npm install -g @anthropic-ai/claude-code
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    $claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
    if ($claudeCmd) {
        Write-Ok "Claude Code installed"
    } else {
        Write-Erro "Failed to install Claude Code."
        Write-Erro "Try manually: npm install -g @anthropic-ai/claude-code"
        exit 1
    }
}

# --- Step 4: Clone and open ---
Write-Info "Step 4/4 - Downloading Mnemosine..."

if (Test-Path "mnemosine") {
    Write-Warn "'mnemosine' folder already exists. Entering it..."
} else {
    & git clone https://github.com/jocsaacesar/mnemosine.git
    Write-Ok "Repository cloned"
}

Set-Location mnemosine

# --- Done ---
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "          Installation complete!               " -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Starting Claude Code..."
Write-Host 'Say "hi" and the setup process starts automatically.' -ForegroundColor White
Write-Host ""

& claude
