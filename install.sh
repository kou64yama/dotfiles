#!/usr/bin/env bash

{
  set -eo pipefail

  : homebrew && {
    if ! command -v brew >/dev/null 2>&1; then
      cat >&2 <<EOF
This requires Homebrew, but not installed it.
See https://brew.sh
EOF
      exit 1
    fi

    brew bundle
  }
}
