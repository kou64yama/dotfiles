#!/usr/bin/env bash

{
  download_url=${DOTFILES_DOWNLOAD_URL:-https://github.com/kou64yama/dotfiles/archive/master.tar.gz}
  dotfiles_dir=${DOTFILES_DIR:-}
  prefix=${PREFIX:-$HOME}

  trap 'rm -rf "$temp"' 0
  temp=$(mktemp -d)
  temp=$(realpath "$temp")

  if [[ -z "$dotfiles_dir" ]]; then
    dotfiles_dir=$temp/dotfiles
    mkdir "$dotfiles_dir"
    curl -#L "$download_url" | tar --strip-components=1 -xf - -C "$dotfiles_dir"
  fi

  sandbox_dir=$temp/sandbox
  mkdir "$sandbox_dir"

  dinst() {
    local dest=$sandbox_dir/$1 src=$dotfiles_dir/$2

    dest=$(realpath "$dest")
    if ! [[ "$dest" =~ ^$sandbox_dir/ ]]; then
      echo "$dest: out of sandbox" >&2
      exit 1
    fi

    src=$(realpath "$src")
    if ! [[ "$src" =~ ^$dotfiles_dir/ ]]; then
      echo "$src: out of dotfiles" >&2
      exit 1
    fi

    cp "$src" "$dest"
  }

  dflush() {
    rsync -rlpt "$sandbox_dir/" "$prefix/"
  }

  dinst .zshrc zsh/zshrc.zsh
  dinst .tmux.conf tmux/tmux.conf
  dinst .gitconfig git/gitconfig
  dinst .hyper.js hyper/hyper.js

  dflush
}
