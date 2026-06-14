#!/usr/bin/env bash

{
  set -eo pipefail

  trap 'rm -rf "$temp"' EXIT
  temp=$(mktemp -d)
  cd "$temp"

  revision=${1:-${GITHUB_SHA:-main}}
  tarball=https://github.com/kou64yama/dotfiles/archive/${revision}.tar.gz
  curl -fsSL --progress-bar "$tarball" | tar --strip-components=1 -xz

  if [[ -n "$CI" ]]; then
    ./install.sh
  else
    ./install.sh -i
  fi
}
