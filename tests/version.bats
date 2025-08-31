#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "README version matches mona --version" {
  readme_version=$(grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' README.md | head -n1 | sed 's/^v//')
  run env MONA_NONINTERACTIVE=1 ./bin/mona --version
  [ "$status" -eq 0 ]
  [ "$output" = "$readme_version" ]
}
