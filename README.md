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
