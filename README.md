# MonaRepo TUI (v0.4.0)

[![CI](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml/badge.svg)](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Base tooling for Monynha server automation with an optional TUI.

## TL;DR

```bash
git clone https://github.com/Monynha-Softwares/MonaRepoTui.git monarepo && cd monarepo
make install-dev
sudo ./bin/mona
```

## Features
- Installer Wizard for GitHub/Docker
  - interactive `.env` helper
  - `docker compose` pull/up/ps/logs
  - README viewer (`less` fallback, `MONA_USE_TUI_READER=1`)
- Bash modules & recipes
- Interactive TUI (bashsimplecurses)
- Dry-run mode
- CI ready (shfmt, shellcheck, bats, editorconfig)

## Install

Clone the repo and install dev deps:

```bash
git clone https://github.com/Monynha-Softwares/MonaRepoTui.git
cd MonaRepoTui
make install-dev
```

### TUI dependency

The interactive menus use [bashsimplecurses](https://github.com/metal3d/bashsimplecurses).
If `ui/bashsimplecurses/simple_curses.sh` is missing, `bin/mona` will try to download it at
runtime (`curl` required). To vendor it instead:

```bash
git submodule add https://github.com/metal3d/bashsimplecurses ui/bashsimplecurses
git submodule update --init --recursive
```

## Quickstart

Run the TUI (root recommended):

```bash
sudo ./bin/mona
```

## Usage

```bash
./bin/mona --help
```

## Installer Wizard

`./bin/mona` ships an installer that can bootstrap projects from GitHub or Docker images.
It detects common actions and runs them one by one, logging everything to
`~/.mona/logs` (override with `$MONA_LOG_DIR`).

Examples:

```bash
# GitHub clone with PAT and README TUI viewer
GITHUB_TOKEN=ghp_xxxx MONA_USE_TUI_READER=1 ./bin/mona

# Preview commands without executing
MONA_DRY_RUN=true ./bin/mona
```

Detected actions include copying `.env.example` to `.env` with an interactive editor,
`docker compose pull/up/ps/logs`, `npm|yarn|pnpm install/build/dev/start`, and more.

## Development

Format and lint:

```bash
make fmt
make lint
```

## Testing

```bash
make test
```

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/contributing.md](docs/contributing.md).

## Security
See [SECURITY.md](SECURITY.md).

## License
MIT © Monynha Softwares

### Monynha Way
Inclusive, accessible and developer‑first.

[Leia em Português](README.pt-BR.md)
