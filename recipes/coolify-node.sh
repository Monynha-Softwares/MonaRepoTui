#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

. "$ROOT/modules/base/base.sh"
. "$ROOT/modules/docker/install.sh"

echo "[mona] Receita: coolify-node"
run_base
run_docker_install

echo "[mona] (TODO) adicionar passos específicos do Coolify aqui."
