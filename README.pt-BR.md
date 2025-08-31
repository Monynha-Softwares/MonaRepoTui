# MonaRepo TUI

[![CI](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml/badge.svg)](https://github.com/Monynha-Softwares/MonaRepoTui/actions/workflows/lint_test.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

TL;DR: toolkit em Bash com TUI opcional para iniciar servidores no estilo Monynha.

## Funcionalidades
- Ponto de entrada único `bin/mona`
- Suporte a dry-run
- Módulos e receitas para tarefas comuns

## Instalação
```bash
git clone https://github.com/Monynha-Softwares/MonaRepoTui.git
cd MonaRepoTui
make install-dev
```

## Início Rápido
```bash
bin/mona --help
```

## Uso
```bash
$ bin/mona --help
MonaRepo v0.4.0

Uso: mona [--dry-run] [--help] [--version]

Flags:
  --dry-run     Mostra ações sem aplicar
  --help        Exibe ajuda e sai
  --version     Exibe versão e sai
Env:
  MONA_NONINTERACTIVE=1  Modo não interativo (CI)
```

## Desenvolvimento
- `make fmt`
- `make lint`
- `make test`

## Testes
Execute toda a suíte:
```bash
make test
```

## Contribuindo
Veja [CONTRIBUTING.md](CONTRIBUTING.md).

## Segurança
Veja [SECURITY.md](SECURITY.md).

## Licença
MIT © Monynha Softwares

> O Jeito Monynha: inclusivo, acessível e focado em DX.
