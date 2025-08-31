#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "backup_file creates timestamped backup" {
  tmp=$(mktemp)
  echo foo >"$tmp"
  run bash -lc "MONA_DIR=$(pwd); . lib/common.sh; backup_file '$tmp'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[mona] backup:"* ]]
  backup=$(ls "$tmp.bak.mona."*)
  [ -f "$backup" ]
}
