#!/usr/bin/env bash
# ==============================================================================
# Tarefa: Verificação e Instalação de Aplicativos Snap
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

echo -e "${BOLD}${BLUE}=== [Desktop] Verificando Aplicativos Snap ===${RESET}"

if ! command -v snap >/dev/null 2>&1; then
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${YELLOW}[AVISO] Snapd não encontrado.${RESET}"
    else
        echo -e "${YELLOW}Snapd não encontrado. Instalando via APT...${RESET}"
        sudo apt-get update && sudo apt-get install -y snapd
    fi
fi

SNAPS=(
    "firefox"
)

INSTALLED_SNAPS=$(snap list 2>/dev/null | awk '{print $1}' || true)

for s in "${SNAPS[@]}"; do
    if echo "$INSTALLED_SNAPS" | grep -qw "$s"; then
        echo -e "${GREEN}✔ Snap já instalado:${RESET} ${s}"
    elif [ "$CHECK_ONLY" = true ]; then
        echo -e "${YELLOW}[AVISO] Snap não instalado:${RESET} ${s}"
    else
        echo -e "${YELLOW}Instalando snap ${s}...${RESET}"
        sudo snap install "$s"
        echo -e "${GREEN}✔ Snap ${s} instalado com sucesso!${RESET}"
    fi
done
