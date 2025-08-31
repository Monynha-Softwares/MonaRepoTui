#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

_color_enabled=1
if [[ -n "${NO_COLOR:-}" || "${MONA_NONINTERACTIVE:-0}" == "1" ]]; then
  _color_enabled=0
fi

_log() {
  local color="$1" msg="$2"
  if [[ $_color_enabled -eq 1 && -n "$color" ]]; then
    printf "[mona] %s\n" "$(printf '\e[%sm%s\e[0m' "$color" "$msg")"
  else
    printf "[mona] %s\n" "$msg"
  fi
}

log_info()    { _log "" "$*"; }
log_warn()    { _log 33 "$*" >&2; }
log_error()   { _log 31 "$*" >&2; }
log_success() { _log 32 "$*"; }

# Backwards compatibility
log()  { log_info "$@"; }
warn() { log_warn "$@"; }
err()  { log_error "$@"; }
