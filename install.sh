#!/usr/bin/env bash

set -eo pipefail

if ! git config --global user.name >/dev/null; then
  echo -n 'Git User Name: ' >&2
  read -r git_user_name || true
fi

if ! git config --global user.email >/dev/null; then
  echo -n 'Git User Email: ' >&2
  read -r git_user_email || true
fi

/usr/bin/env bash stage1.sh
/usr/bin/env bash stage2.sh

if [[ -n "$git_user_name" ]]; then
  git config --global user.name "$git_user_name"
fi
if [[ -n "$git_user_email" ]]; then
  git config --global user.email "$git_user_email"
fi
