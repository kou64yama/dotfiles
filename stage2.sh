#!/usr/bin/env bash

set -eo pipefail

trap 'rm -rf "$work"' 0
work=$(mktemp -d)

mkdir "$work/a"
if [[ -f "$HOME/.dotfiles.tgz" ]]; then
  tar -xf "$HOME/.dotfiles.tgz" -C "$work/a"
fi

mkdir "$work/b"

cp files/git/gitconfig "$work/b/.gitconfig"

cp files/zsh/zshrc.zsh "$work/b/.zshrc"
mkdir "$work/b/.zsh.d"
cp files/zsh/[0-9][0-9]-*.zsh "$work/b/.zsh.d"

mkdir -p "$work/b/.ssh/store" "$work/b/.ssh/cp" "$work/b/.ssh/hosts.d"
echo '# keep' |
  tee "$work/b/.ssh/store/.keep" |
  tee "$work/b/.ssh/cp/.keep" |
  tee "$work/b/.ssh/hosts.d/.keep" >/dev/null
cp files/ssh/config "$work/b/.ssh/config"

cp files/hyper/hyper.js "$work/b/.hyper.js"

mkdir -p "$work/b/.emacs.d"
cp files/emacs/init.el "$work/b/.emacs.d/init.el"

cp files/asdf/asdfrc "$work/b/.asdfrc"

(
  cd "$work"
  if ! diff -urN a b >diff.patch; then
    patch -p1 -u -d "$HOME" <diff.patch
  fi
)

tar -cf "$HOME/.dotfiles.tgz" -C "$work/b" .

os=$(uname -s)

if [[ "$os" = Darwin ]] && ! grep pinentry-program "$HOME/.gnupg/gpg-agent.conf" >/dev/null; then
  echo 'pinentry-program /usr/local/bin/pinentry-mac' >>"$HOME/.gnupg/gpg-agent.conf"
fi

zsh -c "zcompile '$HOME/.zshrc'"
rm -rf "$HOME"/.zsh.d/*.zwc
for i in "$HOME"/.zsh.d/*.zsh; do
  zsh -c "zcompile '$i'"
done
