#!/usr/bin/env bats

setup() { cd "$BATS_TEST_DIRNAME/.."; }

@test "installer modules exist and are executable" {
  [ -x modules/installer/wizard.sh ]
  [ -x modules/installer/github.sh ]
  [ -x modules/installer/docker.sh ]
}
