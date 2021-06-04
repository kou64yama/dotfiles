#!/usr/bin/env bash

set -eo pipefail

os=$(uname -s)

if [[ "$os" = Darwin ]] && ! grep pinentry-program "$HOME/.gnupg/gpg-agent.conf"; then
  echo 'pinentry-program /usr/local/bin/pinentry-mac' >>"$HOME/.gnupg/gpg-agent.conf"
fi

if ! git config --global user.name >/dev/null; then
  echo -n 'Git User Name: ' >&2
  read -r git_user_name
  if [[ -n "$git_user_name" ]]; then
    git config --global user.name "$git_user_name"
  fi
fi

if ! git config --global user.email >/dev/null; then
  echo -n 'Git User Email: ' >&2
  read -r git_user_email
  if [[ -n "$git_user_email" ]]; then
    git config --global user.email "$git_user_email"
  fi
fi
