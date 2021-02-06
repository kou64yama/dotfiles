#!/usr/bin/env bash

{
  set -eo pipefail

  if [[ -z "$DOTFILES" ]]; then
    trap 'rm -rf $temp' 0
    temp=$(mktemp -d)

    curl -fsSL "https://github.com/kou64yama/dotfiles/archive/${GITHUB_SHA:-main}.tar.gz" |
      tar --strip-components=1 -xz -C "$temp"

    (
      cd "$temp"
      DOTFILES="$temp" exec bash install.sh
    )
  fi

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
