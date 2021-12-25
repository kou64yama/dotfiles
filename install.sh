#!/usr/bin/env bash

set -eo pipefail

cd "${0%/*}"

if ! git config --global user.name >/dev/null; then
  echo -n 'Git User Name: ' >&2
  read -r git_user_name || true
fi

if ! git config --global user.email >/dev/null; then
  echo -n 'Git User Email: ' >&2
  read -r git_user_email || true
fi

brew bundle -v --no-lock --file ./stage2/Brewfile
./stage2/install.sh

brew bundle -v --no-lock --file ./stage3/Brewfile
./stage3/install.sh

if [[ -n "$git_user_name" ]]; then
  git config --global user.name "$git_user_name"
fi
if [[ -n "$git_user_email" ]]; then
  git config --global user.email "$git_user_email"
fi
