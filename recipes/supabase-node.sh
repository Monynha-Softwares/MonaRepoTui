#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

. "$ROOT/modules/base/base.sh"
. "$ROOT/modules/docker/install.sh"

echo "[mona] Receita: supabase-node"
run_base
run_docker_install
echo "[mona] (TODO) adicionar steps de Supabase CLI/containers conforme política do projeto."
