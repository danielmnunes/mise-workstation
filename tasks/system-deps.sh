#!/usr/bin/env bash
# ==============================================================================
# Tarefa: Instalação de Compiladores e Dependências do Sistema (APT)
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

echo -e "${BOLD}${BLUE}=== [Sistema] Verificando Compiladores e Bibliotecas C/C++ ===${RESET}"

PACKAGES=(
    build-essential
    pkg-config
    libssl-dev
    ca-certificates
    curl
    git
)

MISSING=()
for pkg in "${PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        MISSING+=("$pkg")
    fi
done

if [ ${#MISSING[@]} -eq 0 ]; then
    echo -e "${GREEN}✔ Todos os pacotes de compilação essenciais já estão instalados.${RESET}"
    exit 0
fi

if [ "$CHECK_ONLY" = true ]; then
    echo -e "${YELLOW}[AVISO] Pacotes ausentes no sistema:${RESET} ${MISSING[*]}"
    exit 0
fi

echo -e "${YELLOW}Pacotes ausentes a instalar via APT:${RESET} ${MISSING[*]}"
echo -e "Solicitando permissão de administrador (sudo)..."
sudo apt-get update
sudo apt-get install -y "${MISSING[@]}"

echo -e "${GREEN}✔ Dependências de sistema instaladas com sucesso!${RESET}"
