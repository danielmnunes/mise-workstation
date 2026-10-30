#!/usr/bin/env bash
# ==============================================================================
# Tarefa: Instalação e Configuração do Docker Engine & Docker Compose
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

echo -e "${BOLD}${BLUE}=== [Sistema] Verificando Docker e Permissões ===${RESET}"

if command -v docker >/dev/null 2>&1; then
    DOCKER_VER=$(docker --version 2>/dev/null || echo "instalado")
    echo -e "${GREEN}✔ Docker já está instalado:${RESET} ${DOCKER_VER}"
elif [ "$CHECK_ONLY" = true ]; then
    echo -e "${YELLOW}[AVISO] Docker não encontrado no sistema.${RESET}"
else
    echo -e "${YELLOW}Docker não encontrado. Configurando repositório oficial Docker APT...${RESET}"
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${VERSION_CODENAME:-jammy}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    echo -e "${GREEN}✔ Docker Engine instalado com sucesso!${RESET}"
fi

# Garante que o usuário pertença ao grupo docker
if id -nG "$USER" | grep -qw "docker"; then
    echo -e "${GREEN}✔ Usuário '$USER' já pertence ao grupo 'docker'.${RESET}"
elif [ "$CHECK_ONLY" = true ]; then
    echo -e "${YELLOW}[AVISO] Usuário '$USER' não pertence ao grupo 'docker'.${RESET}"
else
    echo -e "${YELLOW}Adicionando usuário '$USER' ao grupo 'docker'...${RESET}"
    sudo groupadd -f docker
    sudo usermod -aG docker "$USER"
    echo -e "${GREEN}✔ Usuário adicionado ao grupo docker! (Faça logout/login para aplicar).${RESET}"
fi
