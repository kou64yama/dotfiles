#!/usr/bin/env bash

set -eo pipefail

trap 'if [[ -n "$sandbox" ]]; then rm -rf "$sandbox"; fi' EXIT

sandbox=$(mktemp -d)
files=(
  '0644 .gitconfig                                files/git/gitconfig.ini'
  '0644 .zshrc                                    files/zsh/zshrc.zsh'
  '0644 .zimrc                                    files/zsh/zimrc.zsh'
  '0644 .tmux.conf                                files/tmux/tmux.conf'
  '0644 .config/nvim/init.lua                     files/nvim/init.lua'
  '0644 .config/nvim/lua/config/lazy.lua          files/nvim/lua/config/lazy.lua'
  '0644 .config/nvim/lua/plugins/editorconfig.lua files/nvim/lua/plugins/editorconfig.lua'
  '0644 .config/nvim/lua/plugins/statusline.lua   files/nvim/lua/plugins/statusline.lua'
)
interactive=no

while getopts i OPT; do
  case $OPT in
    i) interactive=yes ;;
  esac
done
shift $((OPTIND - 1))

mkdir -p "$sandbox/a"
if [[ -f "$HOME/.local/var/dotfiles.tgz" ]]; then
  tar -xf "$HOME/.local/var/dotfiles.tgz" -C "$sandbox/a"
fi

mkdir -p "$sandbox/b"
for file in "${files[@]}"; do
  IFS=' ' read -r mode path src <<<"$file"
  dir=$(dirname "$path")
  if [[ ! -d "$sandbox/b/$dir" ]]; then
    mkdir -p "$sandbox/b/$dir"
  fi
  cp "$src" "$sandbox/b/$path"
  chmod "$mode" "$sandbox/b/$path"
done

if (cd "$sandbox" && diff -uNr a b >"$sandbox/patch.diff"); then
  echo "No diff found." >&2
  exit 0
fi

if [[ "$interactive" == yes ]]; then
  cat "$sandbox/patch.diff" >&2
  echo >&2
  echo -n "Apply? (y/N): " >&2
  read -r
  echo >&2

  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Aborted." >&2
    exit 1
  fi
fi

(cd "$HOME"; patch -E -p1 <"$sandbox/patch.diff")

mkdir -p "$HOME/.local/var"
tar -cf "$HOME/.local/var/dotfiles.tgz" -C "$sandbox/b" .
