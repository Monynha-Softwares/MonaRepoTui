#!/usr/bin/env bats

setup() {
  cd "$BATS_TEST_DIRNAME/.."
}

@test "warns about missing bashsimplecurses" {
  local sc="ui/bashsimplecurses/simple_curses.sh"
  rm -f "$sc"
  run env MONA_NONINTERACTIVE=1 ./bin/mona
  [ "$status" -eq 0 ]
  [[ "$output" == *"git submodule add https://github.com/metal3d/bashsimplecurses ui/bashsimplecurses"* ]]
  [[ "$output" == *"git submodule update --init --recursive"* ]]
  rm -f "$sc"
}
