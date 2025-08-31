#!/usr/bin/env bats

setup() { cd "$BATS_TEST_DIRNAME/.."; }

@test "observability scripts are present and executable" {
  [ -x modules/observability/node_exporter.sh ]
  [ -x modules/observability/cadvisor.sh ]
}

@test "nmcli module is present and executable" {
  [ -x modules/network/nmcli.sh ]
}

@test "coolify bootstrap is present and executable" {
  [ -x modules/coolify/bootstrap.sh ]
}
