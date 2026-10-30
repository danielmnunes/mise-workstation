#!/usr/bin/env bash
# ==============================================================================
# Script de Instalação e Atualização de Agentes de IA para Desenvolvimento
# ==============================================================================
# Este script gerencia de forma independente os agentes autônomos de IA,
# garantindo que seus binários fiquem fora dos shims do version manager (Mise)
# e preservem seus próprios mecanismos de auto-update e integração com IDEs.
#
# Uso:
#   ./install-agents.sh          # Verifica e instala os agentes ausentes
#   ./install-agents.sh --check  # Apenas verifica o status das instalações
#   ./install-agents.sh --force  # Reinstala/atualiza todos os agentes
# ==============================================================================

set -uo pipefail

# Cores para formatação no terminal
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"

MODE="install"
if [[ "${1:-}" == "--check" ]]; then
    MODE="check"
elif [[ "${1:-}" == "--force" ]]; then
    MODE="force"
fi

echo -e "${BOLD}${BLUE}=== Gerenciador de Instalação de Agentes de IA ===${RESET}\n"

# Garante que ~/.local/bin exista e esteja no PATH da sessão atual
mkdir -p "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.grok/bin:$PATH"

log_info() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}[AVISO]${RESET} $1"
}

log_err() {
    echo -e "${RED}[ERRO]${RESET} $1"
}

# ------------------------------------------------------------------------------
# 1. OpenCode (OpenCode CLI)
# ------------------------------------------------------------------------------
install_opencode() {
    echo -e "\n${BOLD}▶ OpenCode CLI (opencode)${RESET}"
    if command -v opencode >/dev/null 2>&1 && [[ "$MODE" != "force" ]]; then
        local ver
        ver=$(opencode --version 2>/dev/null || echo "instalado")
        log_ok "OpenCode já está instalado: ${ver}"
    elif [[ "$MODE" == "check" ]]; then
        log_warn "OpenCode não encontrado no PATH."
    else
        log_info "Instalando OpenCode via script oficial..."
        curl -fsSL https://opencode.ai/install | bash
        log_ok "OpenCode instalado com sucesso."
    fi
}

# ------------------------------------------------------------------------------
# 2. OpenAI Codex CLI (codex)
# ------------------------------------------------------------------------------
install_codex() {
    echo -e "\n${BOLD}▶ OpenAI Codex CLI (codex)${RESET}"
    if command -v codex >/dev/null 2>&1 && [[ "$MODE" != "force" ]]; then
        local ver
        ver=$(codex --version 2>/dev/null || echo "instalado")
        log_ok "Codex CLI já está instalado: ${ver}"
    elif [[ "$MODE" == "check" ]]; then
        log_warn "Codex CLI não encontrado no PATH."
    else
        log_info "Instalando Codex CLI via script oficial..."
        curl -fsSL https://chatgpt.com/codex/install.sh | sh || {
            log_warn "Tentando instalação alternativa via npm..."
            npm install -g @openai/codex
        }
        log_ok "Codex CLI instalado com sucesso."
    fi
}

# ------------------------------------------------------------------------------
# 3. Cursor Agent CLI (cursor-agent)
# ------------------------------------------------------------------------------
install_cursor_agent() {
    echo -e "\n${BOLD}▶ Cursor Agent CLI (cursor-agent / agent)${RESET}"
    if command -v cursor-agent >/dev/null 2>&1 && [[ "$MODE" != "force" ]]; then
        local ver
        ver=$(cursor-agent --version 2>/dev/null || echo "instalado")
        log_ok "Cursor Agent já está instalado: ${ver}"
    elif [[ "$MODE" == "check" ]]; then
        log_warn "Cursor Agent não encontrado no PATH."
    else
        log_info "Instalando Cursor Agent via script oficial..."
        curl -fsS https://cursor.com/install | bash
        log_ok "Cursor Agent instalado com sucesso."
    fi
}

# ------------------------------------------------------------------------------
# 4. Herdr Agent Runner (herdr)
# ------------------------------------------------------------------------------
install_herdr() {
    echo -e "\n${BOLD}▶ Herdr Agent Runner (herdr)${RESET}"
    if command -v herdr >/dev/null 2>&1 && [[ "$MODE" != "force" ]]; then
        local ver
        ver=$(herdr --version 2>/dev/null || echo "instalado")
        log_ok "Herdr já está instalado: ${ver}"
    elif [[ "$MODE" == "check" ]]; then
        log_warn "Herdr não encontrado no PATH."
    else
        log_info "Instalando Herdr via script oficial..."
        curl -fsSL https://herdr.dev/install.sh | sh
        log_ok "Herdr instalado com sucesso."
    fi
}

# ------------------------------------------------------------------------------
# 5. Agent Package Manager (apm)
# ------------------------------------------------------------------------------
install_apm() {
    echo -e "\n${BOLD}▶ Agent Package Manager (apm)${RESET}"
    if command -v apm >/dev/null 2>&1 && [[ "$MODE" != "force" ]]; then
        local ver
        ver=$(apm --version 2>/dev/null || echo "instalado")
        log_ok "APM já está instalado: ${ver}"
    elif [[ "$MODE" == "check" ]]; then
        log_warn "APM não encontrado no PATH."
    else
        log_info "Instalando APM via script oficial..."
        curl -sSL https://aka.ms/apm-unix | sh
        log_ok "APM instalado com sucesso."
    fi
}

# ------------------------------------------------------------------------------
# 6. Atlassian Teamwork Graph CLI (twg)
# ------------------------------------------------------------------------------
install_twg() {
    echo -e "\n${BOLD}▶ Atlassian Teamwork Graph CLI (twg)${RESET}"
    if command -v twg >/dev/null 2>&1 && [[ "$MODE" != "force" ]]; then
        local ver
        ver=$(twg --version 2>/dev/null || echo "instalado")
        log_ok "TWG já está instalado: ${ver}"
    elif [[ "$MODE" == "check" ]]; then
        log_warn "TWG não encontrado no PATH."
    else
        log_info "Instalando TWG via script oficial da Atlassian..."
        bash <(curl -fsSL https://teamwork-graph.atlassian.com/cli/install)
        log_ok "TWG instalado com sucesso."
    fi
}

# ------------------------------------------------------------------------------
# 7. GitHub Copilot CLI (copilot / gh-copilot)
# ------------------------------------------------------------------------------
install_copilot() {
    echo -e "\n${BOLD}▶ GitHub Copilot CLI (copilot)${RESET}"
    if gh extension list 2>/dev/null | grep -q "gh-copilot"; then
        log_ok "GitHub Copilot extension (gh copilot) já está instalada."
    elif [[ "$MODE" == "check" ]]; then
        log_warn "Extensão gh-copilot não encontrada."
    else
        if command -v gh >/dev/null 2>&1; then
            log_info "Instalando extensão GitHub Copilot via GitHub CLI..."
            gh extension install github/gh-copilot --force 2>/dev/null || log_warn "Não foi possível autenticar o gh para instalar copilot."
        else
            log_warn "gh (GitHub CLI) não está instalado. Instale o gh primeiro via Mise ou APT."
        fi
    fi
}

# ------------------------------------------------------------------------------
# 8. Antigravity CLI (agy)
# ------------------------------------------------------------------------------
check_agy() {
    echo -e "\n${BOLD}▶ Google Antigravity CLI (agy)${RESET}"
    if command -v agy >/dev/null 2>&1; then
        local ver
        ver=$(agy --version 2>/dev/null || echo "instalado")
        log_ok "Antigravity CLI presente: ${ver}"
    else
        log_warn "agy é distribuído pelo canal Google Antigravity. Certifique-se de que ~/.local/bin/agy está no PATH."
    fi
}

# ------------------------------------------------------------------------------
# 9. Grok CLI (grok)
# ------------------------------------------------------------------------------
check_grok() {
    echo -e "\n${BOLD}▶ Grok CLI (grok)${RESET}"
    if command -v grok >/dev/null 2>&1; then
        local ver
        ver=$(grok --version 2>/dev/null || echo "instalado")
        log_ok "Grok CLI presente: ${ver}"
    else
        log_warn "Grok CLI não encontrado no PATH."
    fi
}

# ------------------------------------------------------------------------------
# Execução dos Módulos
# ------------------------------------------------------------------------------
install_opencode
install_codex
install_cursor_agent
install_herdr
install_apm
install_twg
install_copilot
check_agy
check_grok

echo -e "\n${BOLD}${GREEN}✔ Verificação dos Agentes concluída.${RESET}"
echo -e "${BLUE}Dica:${RESET} Certifique-se de que seu ~/.bashrc contém a linha:"
echo -e "  ${BOLD}export PATH=\"\$HOME/.local/bin:\$HOME/.opencode/bin:\$PATH\"${RESET}\n"
