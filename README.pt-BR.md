# MonaRepo TUI

[![CI](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml/badge.svg)](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Ferramenta base da Monynha para automação de servidores com TUI opcional.

## Resumo

```bash
git clone https://github.com/Monynha-Softwares/MonaRepoTui.git monarepo && cd monarepo
make install-dev
sudo ./bin/mona
```

## Funcionalidades
- Módulos Bash e receitas
- TUI interativo
- Modo dry-run
- CI pronta (shfmt, shellcheck, bats)

## Instalação

```bash
git clone https://github.com/Monynha-Softwares/MonaRepoTui.git
cd MonaRepoTui
make install-dev
```

## Início rápido

```bash
sudo ./bin/mona
```

## Uso

```bash
./bin/mona --help
```

## Desenvolvimento

```bash
make fmt
make lint
```

## Testes

```bash
make test
```

## Contribuindo
Veja [CONTRIBUTING.md](CONTRIBUTING.md) e [docs/contributing.md](docs/contributing.md).

## Segurança
Consulte [SECURITY.md](SECURITY.md).

## Licença
MIT © Monynha Softwares

### Jeito Monynha
Inclusivo, acessível e focado em DX.

[Read in English](README.md)
