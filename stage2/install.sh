#!/usr/bin/env bash

set -eo pipefail

trap 'rm -rf "$work"' 0
work=$(mktemp -d)

mkdir "$work/a"
if [[ -f "$HOME/.dotfiles.tgz" ]]; then
  tar -xf "$HOME/.dotfiles.tgz" -C "$work/a"
fi

mkdir "$work/b"

cp stage2/files/git/gitconfig "$work/b/.gitconfig"

cp stage2/files/zsh/zshrc.zsh "$work/b/.zshrc"
mkdir "$work/b/.zsh.d"
cp stage2/files/zsh/[0-9][0-9]-*.zsh "$work/b/.zsh.d"

mkdir -p "$work/b/.ssh/store" "$work/b/.ssh/cp" "$work/b/.ssh/hosts.d"
echo '# keep' |
  tee "$work/b/.ssh/store/.keep" |
  tee "$work/b/.ssh/cp/.keep" |
  tee "$work/b/.ssh/hosts.d/.keep" >/dev/null
cp stage2/files/ssh/config "$work/b/.ssh/config"

cp stage2/files/hyper/hyper.js "$work/b/.hyper.js"

cp stage2/files/asdf/asdfrc "$work/b/.asdfrc"

(
  cd "$work"
  if ! diff -urN a b >diff.patch; then
    patch -p1 -u -d "$HOME" <diff.patch
  fi
)

tar -cf "$HOME/.dotfiles.tgz" -C "$work/b" .
