# MonaRepo TUI

[![CI](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml/badge.svg)](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

TL;DR: Bash-based toolkit with optional TUI to bootstrap servers the Monynha Way.

## Features
- Single entrypoint `bin/mona`
- Dry-run support
- Modules & recipes for common tasks

## Install
```bash
git clone https://github.com/Monynha-Softwares/MonaRepoTui.git
cd MonaRepoTui
make install-dev
```

## Quickstart
```bash
bin/mona --help
```

## Usage
```bash
$ bin/mona --help
MonaRepo v0.4.0

Usage: mona [--dry-run] [--help] [--version]

Flags:
  --dry-run     Show actions without applying
  --help        Print help and exit
  --version     Print version and exit
Env:
  MONA_NONINTERACTIVE=1  Single-shot non-interactive mode for CI
```

## Development
- `make fmt`
- `make lint`
- `make test`

## Testing
Run the full suite:
```bash
make test
```

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security
See [SECURITY.md](SECURITY.md).

## License
MIT © Monynha Softwares

> The Monynha Way: inclusive, accessible, DX-first.
