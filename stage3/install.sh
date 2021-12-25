#!/usr/bin/env bash

set -eo pipefail

cd "${0%/*}"

trap 'rm -rf "$work"' 0
work=$(mktemp -d)

mkdir "$work"/{a,b}

# Restore
if [[ -f "$HOME"/.dotfiles/stage3.tgz ]]; then
  tar -xf "$HOME"/.dotfiles/stage3.tgz -C "$work"/a
fi

cp files/git/gitconfig "$work"/b/.gitconfig
cp files/hyper/hyper.js "$work"/b/.hyper.js

# Applying
(
  cd "$work"
  if ! diff -urN a b >diff.patch; then
    patch -p1 -u -d "$HOME" <diff.patch
  fi
)

# Archive
mkdir -p "$HOME"/.dotfiles
tar -cf "$HOME"/.dotfiles/stage3.tgz -C "$work"/b .
