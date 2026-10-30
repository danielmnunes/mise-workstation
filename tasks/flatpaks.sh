#!/usr/bin/env bash
# ==============================================================================
# Tarefa: Configuração do Flathub e Instalação de Aplicativos Flatpak
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

echo -e "${BOLD}${BLUE}=== [Desktop] Verificando Aplicativos Flatpak ===${RESET}"

if ! command -v flatpak >/dev/null 2>&1; then
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${YELLOW}[AVISO] Flatpak não encontrado.${RESET}"
    else
        echo -e "${YELLOW}Flatpak não encontrado. Instalando flatpak via APT...${RESET}"
        sudo apt-get update && sudo apt-get install -y flatpak
    fi
fi

# Configura o repositório Flathub
if ! flatpak remotes 2>/dev/null | grep -qw "flathub"; then
    if [ "$CHECK_ONLY" = true ]; then
        echo -e "${YELLOW}[AVISO] Repositório Flathub não configurado.${RESET}"
    else
        echo -e "${BLUE}Configurando repositório Flathub...${RESET}"
        flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    fi
else
    echo -e "${GREEN}✔ Repositório Flathub configurado.${RESET}"
fi

# Aplicativos que o usuário utiliza
APPS=(
    "com.bitwarden.desktop"
    "com.usebruno.Bruno"
    "md.obsidian.Obsidian"
)

INSTALLED_FLATPAKS=$(flatpak list --columns=application 2>/dev/null || true)

for app in "${APPS[@]}"; do
    if echo "$INSTALLED_FLATPAKS" | grep -qw "$app"; then
        echo -e "${GREEN}✔ Flatpak já instalado:${RESET} ${app}"
    elif [ "$CHECK_ONLY" = true ]; then
        echo -e "${YELLOW}[AVISO] Flatpak não instalado:${RESET} ${app}"
    else
        echo -e "${YELLOW}Instalando ${app} via Flathub...${RESET}"
        flatpak install -y flathub "$app"
        echo -e "${GREEN}✔ ${app} instalado com sucesso!${RESET}"
    fi
done
