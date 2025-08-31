# MonaRepo — Monynha Softwares

**Version:** v0.1.0

A base monorepo (Bash-first) to automate VM/server bootstrap with an optional TUI powered by [`bashsimplecurses`](https://github.com/metal3d/bashsimplecurses).
Use this as the starting point for Codex/agents to extend modules and recipes.

## Features
- Single entrypoint: `bin/mona` — interactive TUI (↑/↓, Enter, Q) with a heart header ❤
- Flows: Quick Start, Distro Upgrade, Network (Netplan), Users & SSH, Hostname/hosts, Run Recipe
- Dry-run mode (`--dry-run`) to preview actions
- CI ready (ShellCheck + BATS), Makefile targets
- Cloud-init template for first-boot provisioning

## Getting Started

```bash
# clone
git clone <your-repo> monarepo && cd monarepo

# (optional) add simple curses as submodule (or rely on runtime downloader in bin/mona)
git submodule add https://github.com/metal3d/bashsimplecurses ui/bashsimplecurses
git submodule update --init --recursive

# run TUI (recommended with sudo/root)
sudo ./bin/mona
```

### Non-interactive/CI flags
- `--version`      : prints version and exits
- `--help`         : prints help and exits
- `--dry-run`      : prints actions instead of applying
- `MONA_NONINTERACTIVE=1` : single-shot non-interactive mode (no curses, no actions)

### Directory Layout

```
bin/            # entrypoints
lib/            # shared helpers (future work for agents)
modules/        # idempotent modules (base, docker, ...)
recipes/        # orchestration of modules per "role"
templates/      # cloud-init and systemd
tests/          # bats tests
ui/             # optional bashsimplecurses submodule (or runtime fetch)
.github/workflows/ci.yml
```

## Cloud-init quick start
Use `templates/cloud-init/user-data.yaml` as user-data for new VMs. It clones your repo into `/opt/monarepo` and runs a recipe.

## Contributing
- Lint Shell: `make lint` (ShellCheck)
- Tests: `make test` (BATS)
- Keep modules idempotent: **probe → apply → verify**
- Prefer `apply` helper (respects `--dry-run`).

## License
MIT — see [LICENSE](LICENSE).


## Included Recipes (examples)
- `recipes/coolify-node.sh` — base + docker + coolify bootstrap (network/dirs)
- `recipes/monitoring-node.sh` — base + docker + node_exporter + cAdvisor
- `recipes/supabase-node.sh` — base + docker (hook para Supabase)

## Project Installer (Wizard)
Use the TUI option **“Instalar/Configurar Projeto (GitHub/Docker)”** to:
- List or select a GitHub repo (Monynha-Softwares by default) and clone it
- Or pull/run a Docker image quickly
- Then MonaRepo detects common post‑clone actions (e.g., copy `.env.example`, `docker compose up -d`, `npm/pnpm/yarn install`, `make setup`, `supabase start`) and lets you run them step‑by‑step while logging output.

Logs are stored in `~/.mona/logs` (or `$MONA_LOG_DIR`). `--dry-run` prints commands without executing.

### Installer extras (v0.4.0)
- **GitHub PAT**: set `GITHUB_TOKEN` to avoid rate limits and access private repos.
- **Interactive `.env`**: when a project has `.env.example`, choose “Criar .env interativo” to fill values key-by-key.
- **Docker Compose advanced**: auto-detects `docker compose` (plugin) or `docker-compose`; offers `pull`, `up -d --remove-orphans`, `ps`, `logs -f`.
- **TUI README viewer** (experimental): set `MONA_USE_TUI_READER=1` to view README inside the TUI; otherwise falls back to `less`.
