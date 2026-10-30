#!/usr/bin/env bash
# ==============================================================================
# Script de Bootstrap da Estação de Trabalho via Mise
# ==============================================================================
# Este script prepara o ambiente do zero:
#   1. Instala o binário do Mise em ~/.local/bin (se ausente).
#   2. Ativa o hook do Mise em ~/.bashrc e ~/.zshrc.
#   3. Copia a configuração (config.toml) e os módulos (tasks/) para ~/.config/mise/.
#   4. Executa 'mise run check:all' (ou 'mise run bootstrap' para instalação).
#
# Uso:
#   ./setup-mise.sh --dry-run   # Simula todos os passos sem alterar nada
#   ./setup-mise.sh --check     # Apenas checa o status de tudo no sistema
#   ./setup-mise.sh             # Modo interativo com confirmação
#   ./setup-mise.sh --yes       # Executa o bootstrap completo (CI/CD / não interativo)
# ==============================================================================

set -euo pipefail

GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
RED="\033[1;31m"
BOLD="\033[1m"
RESET="\033[0m"

DRY_RUN=false
AUTO_YES=false
CHECK_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --check) CHECK_ONLY=true ;;
        --yes|-y) AUTO_YES=true ;;
    esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_SOURCE="${SCRIPT_DIR}/config.toml"
TASKS_SOURCE="${SCRIPT_DIR}/tasks"
MISE_CONFIG_DIR="${HOME}/.config/mise"

echo -e "${BOLD}${CYAN}=== Setup de Estação de Trabalho via Mise ===${RESET}\n"

if [ "$CHECK_ONLY" = true ]; then
    echo -e "${BLUE}Modo de verificação de status selecionado.${RESET}\n"
    bash "${TASKS_SOURCE}/system-deps.sh" --check
    echo ""
    bash "${TASKS_SOURCE}/docker.sh" --check
    echo ""
    bash "${TASKS_SOURCE}/fonts.sh" --check
    echo ""
    bash "${TASKS_SOURCE}/flatpaks.sh" --check
    echo ""
    bash "${TASKS_SOURCE}/snaps.sh" --check
    echo ""
    bash "${TASKS_SOURCE}/agents.sh" --check
    echo -e "\n${GREEN}✔ Verificação concluída.${RESET}"
    exit 0
fi

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}MODO SIMULAÇÃO (--dry-run) ATIVO: Nenhuma alteração real será feita no sistema.${RESET}\n"
fi

# 1. Mise Binary
echo -e "${BOLD}1. Verificando o Mise...${RESET}"
if command -v mise >/dev/null 2>&1; then
    MISE_BIN="$(command -v mise)"
    echo -e "${GREEN}✔ Mise já instalado em:${RESET} ${MISE_BIN} ($(${MISE_BIN} --version))\n"
elif [ -f "${HOME}/.local/bin/mise" ]; then
    MISE_BIN="${HOME}/.local/bin/mise"
    echo -e "${GREEN}✔ Mise encontrado em:${RESET} ${MISE_BIN} ($(${MISE_BIN} --version))\n"
else
    echo -e "${BLUE}ℹ Instalando Mise via https://mise.run...${RESET}"
    if [ "$DRY_RUN" = true ]; then
        echo -e "[SIMULAÇÃO] Executaria: curl -fsSL https://mise.run | sh"
        MISE_BIN="${HOME}/.local/bin/mise"
    else
        curl -fsSL https://mise.run | sh
        MISE_BIN="${HOME}/.local/bin/mise"
        echo -e "${GREEN}✔ Mise instalado em:${RESET} ${MISE_BIN}\n"
    fi
fi

export PATH="${HOME}/.local/bin:${PATH}"

# 2. Shell Integration
echo -e "${BOLD}2. Verificando integração com Shell (~/.bashrc e ~/.zshrc)...${RESET}"
setup_shell_file() {
    local shell_rc="$1"
    local shell_name="$2"
    local hook_line="eval \"\$(${HOME}/.local/bin/mise activate ${shell_name})\""

    if [ -f "$shell_rc" ]; then
        if grep -q "mise activate" "$shell_rc"; then
            echo -e "${GREEN}✔ ${shell_rc} já possui o hook do Mise.${RESET}"
        else
            echo -e "${BLUE}ℹ Adicionando ativação do Mise em ${shell_rc}...${RESET}"
            if [ "$DRY_RUN" = true ]; then
                echo -e "[SIMULAÇÃO] Adicionaria a ${shell_rc}: ${hook_line}"
            else
                echo -e "\n# Mise version manager\n${hook_line}" >> "$shell_rc"
                echo -e "${GREEN}✔ Hook adicionado a ${shell_rc}.${RESET}"
            fi
        fi
    fi
}
setup_shell_file "${HOME}/.bashrc" "bash"
setup_shell_file "${HOME}/.zshrc" "zsh"
echo ""

# 3. Copy Config and Tasks to ~/.config/mise/
echo -e "${BOLD}3. Aplicando configurações globais do Mise...${RESET}"
if [ "$DRY_RUN" = true ]; then
    echo -e "[SIMULAÇÃO] Copiaria config.toml e pasta tasks/ para ${MISE_CONFIG_DIR}/"
else
    mkdir -p "${MISE_CONFIG_DIR}"
    cp "${CONFIG_SOURCE}" "${MISE_CONFIG_DIR}/config.toml"
    cp -r "${TASKS_SOURCE}" "${MISE_CONFIG_DIR}/"
    echo -e "${GREEN}✔ Arquivos aplicados com sucesso em:${RESET} ${MISE_CONFIG_DIR}"
fi
echo ""

# 4. Bootstrap / Execução
echo -e "${BOLD}4. Orquestração das Ferramentas${RESET}"
if [ "$DRY_RUN" = true ]; then
    echo -e "[SIMULAÇÃO] Executaria: mise run bootstrap"
    echo -e "\n${GREEN}✔ Simulação concluída com sucesso.${RESET}"
    exit 0
fi

if [ "$AUTO_YES" = false ]; then
    read -p "Deseja iniciar a instalação completa de todas as ferramentas agora? [S/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]] && [ -n "$REPLY" ]; then
        echo -e "${YELLOW}Instalação adiada. Quando quiser instalar, basta rodar:${RESET} mise run bootstrap"
        exit 0
    fi
fi

"${MISE_BIN}" run bootstrap
echo -e "\n${BOLD}${GREEN}🎉 Tudo pronto! Recarregue seu terminal com: source ~/.bashrc${RESET}\n"
