#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "bin/mona --version prints version" {
  run env MONA_NONINTERACTIVE=1 ./bin/mona --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "bin/mona --help exits 0" {
  run ./bin/mona --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "bin/mona --dry-run exits 0" {
  run env MONA_NONINTERACTIVE=1 ./bin/mona --dry-run <<<""
  [ "$status" -eq 0 ]
}
