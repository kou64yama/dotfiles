#!/usr/bin/env bash

{
  set -eo pipefail

  trap 'rm -rf "$temp"' 0
  temp=$(mktemp -d)
  cd "$temp"

  tarball=https://github.com/kou64yama/dotfiles/archive/${GITHUB_SHA:-main}.tar.gz
  curl -fsSL --progress-bar "$tarball" | tar --strip-components=1 -xz

  if [[ -n "$CI" ]]; then
    ./install.sh
  else
    ./install.sh -i
  fi
}
