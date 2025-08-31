This folder is intended to host the `bashsimplecurses` submodule or a downloaded `simple_curses.sh`.

Option A — Submodule:
  git submodule add https://github.com/metal3d/bashsimplecurses ui/bashsimplecurses
  git submodule update --init --recursive

Option B — Runtime download:
  `bin/mona` will attempt to fetch `simple_curses.sh` via curl if missing.
