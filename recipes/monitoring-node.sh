#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"

. "$ROOT/modules/base/base.sh"
. "$ROOT/modules/docker/install.sh"
. "$ROOT/modules/observability/node_exporter.sh"
. "$ROOT/modules/observability/cadvisor.sh"

echo "[mona] Receita: monitoring-node"
run_base
run_docker_install
run_node_exporter
run_cadvisor
echo "[mona] monitoring-node concluída."
