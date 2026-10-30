# Relatório de Diagnóstico do Sistema & Compatibilidade com Mise (mise.jdx.dev)

> **Data da análise:** 29 de Outubro de 2026  
> **Sistema Operacional:** Linux x86_64 (Ubuntu)  
> **Status:** Diagnóstico concluído (modo somente leitura — nenhuma alteração ou instalação foi executada).

---

## 1. Visão Geral do Cenário Atual

Atualmente, o ambiente possui diversas ferramentas de desenvolvimento instaladas e gerenciadas por múltiplos mecanismos independentes:
- **[NVM](https://github.com/nvm-sh/nvm):** Gerencia 5 versões do Node.js.
- **[SDKMAN!](https://sdkman.io):** Gerencia múltiplas versões de Java (JDK), Maven, Gradle e Spring Boot CLI.
- **[Rustup / Cargo](https://rustup.rs):** Gerencia a toolchain Rust e binários compilados em Rust.
- **[PNPM](https://pnpm.io) & [Bun](https://bun.sh):** Instalados via scripts standalone em diretórios do usuário.
- **[Go](https://go.dev):** Instalado manualmente via tarball em `/usr/local/go`.
- **[uv](https://astral.sh/uv):** Instalado como binário independente em `~/.local/bin`.
- **APT / Repositórios do SO:** Gerenciam utilitários CLI modernos (como `ripgrep`, `bat`, `eza`, `zoxide`, `gh`, `glab`, `jq`), ferramentas de sistema (`docker`, `git`, `make`, `gcc`) e o Python da distribuição.
- **Flatpak & Snap:** Gerenciam aplicações desktop (`Obsidian`, `Bruno Desktop`, `Bitwarden`, `Firefox`).

No arquivo `~/.bashrc`, esses múltiplos gerenciadores demandam diversos scripts de inicialização (`nvm.sh`, `sdkman-init.sh`, `cargo/env`, `bun`, `pnpm`), o que gera redundância e aumenta a latência de inicialização de novas sessões de terminal.

---

## 2. O que é o [mise-en-place (mise.jdx.dev)](https://mise.jdx.dev)?

O **mise** (anteriormente conhecido como `rtx`) é um gerenciador universal de ferramentas de desenvolvimento escrito em Rust. Ele unifica em um único binário ultra-rápido:
1. **Substituto para gerenciadores de linguagem:** Substitui `nvm`, `fnm`, `sdkman`, `pyenv`, `rbenv`, `gvm`, etc.
2. **Suporte a backends múltiplos:**
   - **Core backends:** Node, Python, Go, Rust, Java, Bun, Deno, etc.
   - **Registry & Aqua:** Centenas de ferramentas de linha de comando obtidas diretamente de releases do GitHub com validação de integridade.
   - **Backends de ecossistemas:** `cargo:...`, `npm:...`, `go:...`, `pipx:...`, além de todo o ecossistema de plugins legados do `asdf`.
3. **Arquivo único de configuração:** Permite declarar todas as ferramentas de um projeto em um único arquivo `mise.toml`.

---

## 3. O que você tem instalado vs. O que pode ser migrado para o Mise

### A. Runtimes e Linguagens de Programação

Todas as linguagens e runtimes abaixo estão atualmente fragmentadas e **podem ser 100% gerenciadas pelo mise**:

| Ferramenta | Onde/Como está instalada hoje | Versões encontradas | Suporte Mise | Backend no Mise | Comando equivalente no Mise |
|---|---|---|:---:|:---:|---|
| **Node.js** | NVM (`~/.nvm`) | `v26.13.0`, `v24.22.1`, `v24.22.0`, `v24.21.0`, `v24.20.0` | Sim | `core` | `mise use node@26.13.0` |
| **npm** | NVM (`~/.nvm`) | `12.2.1` | Sim | `core` | Acompanha o Node ou `mise use npm@latest` |
| **pnpm** | Standalone (`~/.local/share/pnpm`) | `12.16.1` | Sim | `core` | `mise use pnpm@latest` |
| **Bun** | Standalone (`~/.bun/bin`) | `1.4.4` | Sim | `core` | `mise use bun@latest` |
| **Java (JDK)** | SDKMAN! (`~/.sdkman/candidates/java`) | `17.0.12-oracle`, `21.0.12-oracle`, `25.0.4-oracle` | Sim | `core` / `asdf-java` | `mise use java@oracle-21` (ou temurin/corretto) |
| **Go** | Manual em `/usr/local/go` | `1.27.2` | Sim | `core` | `mise use go@1.27.2` |
| **Rust** | Rustup (`~/.cargo/bin`) | `1.99.1` (rustc, cargo, rust-analyzer) | Sim | `core` | `mise use rust@latest` *(ver nota)* |
| **Python** | APT do sistema (`/usr/bin/python3`) | `3.14.4` | Sim | `core` | `mise use python@3.14` (baixa standalone sem afetar o sistema) |
| **uv / uvx** | Standalone (`~/.local/bin/uv`) | `0.13.6` | Sim | `registry` | `mise use uv@latest` |

> [!NOTE]
> Para o Rust, o Mise pode gerenciar toolchains diretamente (`mise use rust`). Porém, caso você use cross-compilação profunda com múltiplos targets exóticos (`rustup target add`), o `rustup` pode ser mantido ou integrado ao mise.

---

### B. Ferramentas de Build & Frameworks JVM (Substituindo o SDKMAN!)

O Mise elimina completamente a necessidade do SDKMAN! no seu terminal:

| Ferramenta | Onde/Como está instalada hoje | Versão atual | Suporte Mise | Backend no Mise | Comando equivalente no Mise |
|---|---|---|:---:|:---:|---|
| **Maven** | SDKMAN! (`~/.sdkman/candidates/maven`) | `3.9.16` | Sim | `registry` | `mise use maven@3.9.16` |
| **Gradle** | SDKMAN! (`~/.sdkman/candidates/gradle`) | `9.7.1` | Sim | `registry` | `mise use gradle@9.7.1` |
| **Spring Boot CLI** | SDKMAN! (`~/.sdkman/candidates/springboot`) | `4.1.2`, `4.1.0` | Sim | `asdf` / `aqua` | `mise use spring-boot-cli@latest` |

---

### C. Utilitários Modernos de Terminal (atualmente via APT ou manuais)

Muitas ferramentas modernas que hoje dependem do APT (e que em muitas distribuições ficam com versões desatualizadas) podem ser gerenciadas pelo Mise em nível de usuário, sem necessidade de `sudo`:

| Ferramenta | Onde/Como está instalada hoje | Versão atual | Suporte Mise | Backend no Mise | Comando equivalente no Mise |
|---|---|---|:---:|:---:|---|
| **ripgrep (`rg`)** | APT (`/usr/bin/rg`) | `15.2.0` | Sim | `registry` / `aqua` | `mise use ripgrep@latest` |
| **bat** | APT (`/usr/bin/bat`) | `0.26.1` | Sim | `registry` / `aqua` | `mise use bat@latest` |
| **eza** | APT (`/usr/bin/eza`) | `0.23.5` | Sim | `registry` / `aqua` | `mise use eza@latest` |
| **zoxide** | APT (`/usr/bin/zoxide`) | `0.10.0` | Sim | `registry` / `aqua` | `mise use zoxide@latest` |
| **jq** | APT (`/usr/bin/jq`) | `1.8.1` | Sim | `registry` / `aqua` | `mise use jq@latest` |
| **GitHub CLI (`gh`)** | APT (`/usr/bin/gh`) | `2.46.0` | Sim | `registry` / `aqua` | `mise use gh@latest` |
| **GitLab CLI (`glab`)** | APT (`/usr/bin/glab`) | `1.53.0` | Sim | `registry` / `aqua` | `mise use glab@latest` |
| **D2 (Diagramas)** | Standalone (`~/.local/bin/d2`) | `0.9.0` | Sim | `registry` / `aqua` | `mise use d2@latest` |

---

### D. Binários Globais de Ecossistemas (Cargo, PNPM, Go)

Binários instalados via gerenciadores de pacotes específicos podem ser gerenciados centralizadamente pelo Mise:

| Ferramenta | Onde/Como está instalada hoje | Versão atual | Backend no Mise | Comando equivalente no Mise |
|---|---|---|:---:|---|
| **worktrunk (`wt`)** | `cargo install` (`~/.cargo/bin/wt`) | `0.74.0` | `cargo` | `mise use cargo:worktrunk` |
| **Bruno CLI (`bru`)** | `pnpm add -g @usebruno/cli` | `4.3.0` | `npm` | `mise use npm:@usebruno/cli` |
| **Delve (`dlv`)** | `go install` (`~/go/bin/dlv`) | Compilado | `go` | `mise use go:github.com/go-delve/delve/cmd/dlv@latest` |
| **gopls** | `go install` (`~/go/bin/gopls`) | Compilado | `go` | `mise use go:golang.org/x/tools/gopls@latest` |
| **goimports** | `go install` (`~/go/bin/goimports`) | Compilado | `go` | `mise use go:golang.org/x/tools/cmd/goimports@latest` |
| **goplay** | `go install` (`~/go/bin/goplay`) | Compilado | `go` | `mise use go:github.com/haya14busa/goplay@latest` |
| **impl** | `go install` (`~/go/bin/impl`) | Compilado | `go` | `mise use go:github.com/josharian/impl@latest` |

---

## 4. O que NÃO deve ser migrado para o Mise

Nem tudo deve ser gerenciado por um version manager. Os seguintes componentes encontrados no seu sistema **devem permanecer onde estão**:

1. **Docker e Docker Compose (`docker-ce`, `docker-compose-plugin`)**:
   - Requerem daemon de sistema em background (`dockerd`), serviços systemd, manipulação de interfaces de rede e regras iptables/cgroups no kernel Linux. Devem continuar sob controle do APT.
2. **Git do Sistema (`git`)**:
   - O Git básico do sistema é uma dependência essencial do próprio sistema operacional e do Mise (para clonar repositórios de plugins e ferramentas).
3. **Compiladores C/C++ de Base (`gcc`, `g++`, `make`, `build-essential`)**:
   - Necessários para compilar extensões nativas e pacotes glibc do Linux.
4. **Aplicações Desktop GUI (Flatpak, Snap, AppImage)**:
   - `Firefox`, `Obsidian`, `Bruno Desktop`, `Bitwarden`, `Zed`.
5. **Agentes de IA e Ferramentas Especializadas em `~/.local/bin` / `~/.opencode`**:
   - `antigravity-cli` (`agy`), `cursor-agent`, `codex`, `grok`, `herdr`, `opencode`, `apm`, bem como scripts de automação local (ex: `handy-toggle-transcription`).

---

## 5. Exemplo Prático: Como ficaria um `mise.toml` Global

Se você decidisse adotar o Mise no futuro para gerenciar suas ferramentas globais, seu arquivo de configuração `~/.config/mise/config.toml` ficaria tão simples e limpo quanto:

```toml
[tools]
# Runtimes & Linguagens
node = "26.13.0"
bun = "1.4.4"
pnpm = "latest"
java = "oracle-21"
go = "1.27.2"
rust = "latest"
python = "3.14"

# Ferramentas de Build
maven = "3.9.16"
gradle = "9.7.1"

# CLI & Utilitários
uv = "latest"
ripgrep = "latest"
bat = "latest"
eza = "latest"
zoxide = "latest"
jq = "latest"
gh = "latest"
glab = "latest"
d2 = "latest"

# Pacotes de outros ecossistemas
"cargo:worktrunk" = "latest"
"npm:@usebruno/cli" = "latest"
"go:golang.org/x/tools/gopls" = "latest"
"go:github.com/go-delve/delve/cmd/dlv" = "latest"
```

### Vantagens Desta Abordagem:
1. **Limpeza do `~/.bashrc`:** Permite remover dezenas de linhas de inicialização (`nvm`, `sdkman`, `cargo/env`, `bun`, `pnpm`), deixando apenas a ativação ultra-rápida do Mise:
   ```bash
   eval "$(mise activate bash)"
   ```
2. **Controle por Repositório:** Em qualquer projeto, você pode colocar um arquivo `.mise.toml` especificando, por exemplo, `node = "24.22.1"` e `java = "17"`, e o Mise alternará as versões automaticamente assim que você entrar no diretório (`cd`), sem necessidade de rodar `nvm use` ou `sdk use`.
3. **Instalação sem `sudo`:** Todas as ferramentas ficam isoladas no diretório `~/.local/share/mise`, garantindo que atualizações não quebrem pacotes do sistema operacional.

---

> [!IMPORTANT]
> **Lembrete de Conformidade:** Nenhuma ferramenta foi alterada, instalada ou desinstalada durante este processo. Todas as configurações e binários atuais permanecem intactos.
