#!/usr/bin/env bash

{
  set -eo pipefail

  if ! command -v brew >/dev/null 2>&1; then
    cat >&2 <<EOF
This requires Homebrew.
For more information, see https://brew.sh
EOF
    exit 1
  fi

  trap 'rm -rf "$temp"' 0
  temp=$(mktemp -d)
  cd "$temp"

  tarball=https://github.com/kou64yama/dotfiles/archive/${GITHUB_SHA:-main}.tar.gz
  curl -fsSL --progress-bar "$tarball" | tar --strip-components=1 -xz
  /usr/bin/env bash install.sh
}
