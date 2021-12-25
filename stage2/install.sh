#!/usr/bin/env bash

set -eo pipefail

cd "${0%/*}"

trap 'rm -rf "$work"' 0
work=$(mktemp -d)

mkdir "$work"/{a,b}

# Restore
if [[ -f "$HOME"/.dotfiles/stage2.tgz ]]; then
  tar -xf "$HOME"/.dotfiles/stage2.tgz -C "$work"/a
fi

# Install ZSH settings
cp files/zsh/zshrc.zsh "$work"/b/.zshrc
mkdir "$work"/b/.zsh.d
cp files/zsh/[0-9][0-9]-*.zsh "$work"/b/.zsh.d

# Install OpenSSH settings
mkdir -p "$work"/b/.ssh/{store,cp,hosts.d}
cp files/ssh/config "$work"/b/.ssh/config
echo '# keep' | tee "$work"/b/.ssh/{store,cp,hosts.d}/.keep >/dev/null

# Install Emacs settings
mkdir -p "$work"/b/.emacs.d/local
cp files/emacs/init.el "$work"/b/.emacs.d/init.el
echo '# keep' | tee "$work"/b/.emacs.d/local/.keep >/dev/null

# Applying
(
  cd "$work"
  if ! diff -urN a b >diff.patch; then
    patch -p1 -u -d "$HOME" <diff.patch
  fi
)

# Archive
mkdir -p "$HOME"/.dotfiles
tar -cf "$HOME"/.dotfiles/stage2.tgz -C "$work"/b .

# Compile ZSH scripts
zsh -c "zcompile '$HOME/.zshrc'"
rm -rf "$HOME"/.zsh.d/*.zwc
for i in "$HOME"/.zsh.d/*.zsh; do
  zsh -c "zcompile '$i'"
done
