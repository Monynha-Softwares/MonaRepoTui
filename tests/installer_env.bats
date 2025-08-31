#!/usr/bin/env bats

setup() { cd "$BATS_TEST_DIRNAME/.."; }

@test "wizard provides env_interactive_from_example function" {
  run bash -lc 'source modules/installer/wizard.sh; type -t env_interactive_from_example'
  [ "$status" -eq 0 ]
  [[ "$output" == "function" ]]
}
