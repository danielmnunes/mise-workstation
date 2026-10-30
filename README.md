# Automação de Estação de Trabalho via Mise (mise.jdx.dev)

Estrutura completa e declarativa para provisionar, gerenciar e auditar seu ambiente de desenvolvimento Linux/Ubuntu do zero.

---

## 📁 Estrutura do Diretório

```text
.
├── config.toml            # Configuração unificada do Mise: [tools] e [tasks]
├── setup-mise.sh          # Script inicial de bootstrap e verificação da máquina
├── tasks/                 # Módulos idempotentes de provisionamento
│   ├── system-deps.sh     # Compiladores e bibliotecas C/C++ (build-essential, etc.)
│   ├── docker.sh          # Docker Engine, Compose e permissões de usuário
│   ├── fonts.sh           # JetBrains Mono Nerd Font (para Starship e Eza)
│   ├── flatpaks.sh        # Flathub + Bitwarden, Bruno e Obsidian
│   ├── snaps.sh           # Aplicativos Snap (Firefox, etc.)
│   └── agents.sh          # Agentes de IA (OpenCode, Codex, Herdr, Cursor, etc.)
└── diagnostico-mise.md    # Relatório detalhado da auditoria do sistema
```

---

## 🚀 Como Usar

### 1. Apenas Verificar o Status do Sistema (Não altera nada)
```bash
./setup-mise.sh --check
```

### 2. Simular o Processo de Instalação (Dry-run)
```bash
./setup-mise.sh --dry-run
```

### 3. Executar o Setup Completo (Interativo)
```bash
./setup-mise.sh
```

---

## 🛠️ Comandos do Mise (após o setup)

Com o `config.toml` aplicado, você pode disparar qualquer módulo diretamente pelo Mise:

```bash
mise run check:all        # Verifica o status de todos os módulos
mise run bootstrap        # Executa o provisionamento completo do zero
mise run system:deps      # Apenas compiladores e bibliotecas APT
mise run system:docker    # Apenas Docker e permissões
mise run install:fonts    # Apenas as fontes Nerd Fonts
mise run install:flatpaks # Apenas os Flatpaks
mise run install:agents   # Apenas os Agentes de IA
mise run mise:tools       # Apenas as ferramentas declaradas no [tools]
```
