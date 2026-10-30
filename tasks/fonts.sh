#!/usr/bin/env bash
# ==============================================================================
# Tarefa: Instalação de Nerd Fonts (JetBrains Mono) para Ícones no Terminal
# ==============================================================================
set -euo pipefail

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
BOLD="\033[1m"
RESET="\033[0m"

CHECK_ONLY=false
if [[ "${1:-}" == "--check" ]]; then
    CHECK_ONLY=true
fi

FONT_DIR="${HOME}/.local/share/fonts/JetBrainsMonoNerd"

echo -e "${BOLD}${BLUE}=== [Terminal] Verificando Nerd Fonts (Starship / Eza) ===${RESET}"

if [ -d "$FONT_DIR" ] && [ "$(ls -A "$FONT_DIR" 2>/dev/null)" ]; then
    echo -e "${GREEN}✔ JetBrains Mono Nerd Font já está instalada em:${RESET} ${FONT_DIR}"
    exit 0
fi

if [ "$CHECK_ONLY" = true ]; then
    echo -e "${YELLOW}[AVISO] JetBrains Mono Nerd Font não encontrada em ${FONT_DIR}.${RESET}"
    exit 0
fi

echo -e "${YELLOW}Baixando JetBrains Mono Nerd Font dos releases oficiais...${RESET}"
mkdir -p "$FONT_DIR"
TMP_ZIP=$(mktemp --suffix=.zip)

curl -fsSL -o "$TMP_ZIP" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"

echo -e "${BLUE}Extraindo fontes...${RESET}"
unzip -qo "$TMP_ZIP" -d "$FONT_DIR"
rm -f "$TMP_ZIP"

if command -v fc-cache >/dev/null 2>&1; then
    echo -e "${BLUE}Atualizando cache de fontes do sistema...${RESET}"
    fc-cache -f "${HOME}/.local/share/fonts"
fi

echo -e "${GREEN}✔ JetBrains Mono Nerd Font instalada com sucesso!${RESET}"
