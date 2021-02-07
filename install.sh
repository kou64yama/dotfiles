#!/usr/bin/env bash

{
  set -eo pipefail

  # Check Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    cat >&2 <<EOF
kou64yama/dotfiles requires Homebrew, but not installed it.
See https://brew.sh
EOF
    exit 1
  fi

  trap 'rm -rf $temp' 0
  temp=$(mktemp -d)

  if [[ -z "$DOTFILES" ]]; then
    tarball=https://github.com/kou64yama/dotfiles/archive/${GITHUB_SHA:-main}.tar.gz
    echo "==> Downloading $tarball"
    curl -fsSL# "$tarball" | tar --strip-components=1 -xz -C "$temp"

    cd "$temp"
    DOTFILES="$temp" exec bash install.sh
  else
    cd "$DOTFILES"
  fi

  : Installing RC scripts into the sandbox && {
    echo "==> Installing RC scripts into the sandbox"

    sandbox=$temp/b
    mkdir -p "$sandbox"

    mkdir "$sandbox/.zsh"
    cp zsh/zshrc.zsh "$sandbox/.zshrc"
    cp zsh/[1-9][0-9]-*.zsh "$sandbox/.zsh"

    cp git/gitconfig "$sandbox/.gitconfig"

    cp tmux/tmux.conf "$sandbox/.tmux.conf"

    mkdir "$sandbox/.ssh"
    cp ssh/config "$sandbox/.ssh/config"

    cp hyper/hyper.js "$sandbox/.hyper.js"
  }

  : Applying patch to RC scripts && {
    echo "==> Applying patch to RC scripts"

    prefix="${PREFIX:-$HOME}"

    mkdir "$temp/a"
    if [[ -f "$prefix/.dotfiles/sandbox.tgz" ]]; then
      tar -xf "$prefix/.dotfiles/sandbox.tgz" -C "$temp/a"
    fi

    (
      cd "$temp"
      diff -urN a b | patch -p1 -u -d "$prefix" || true
    )

    mkdir -p "$prefix/.dotfiles"
    tar -C "$temp/b" -cf "$prefix/.dotfiles/sandbox.tgz" .
  }

  : Install homebrew formulae && {
    echo "==> Install homebrew formulae"
    if [[ -z "$DOTFILES_SKIP_BREW_INSTALL" ]]; then
      brew bundle --no-lock
    else
      echo "Skipping brew bundle"
    fi
  }
}
