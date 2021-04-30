#!/usr/bin/env bash

set -eo pipefail

prompt() {
  echo -n "$1" >&2
  local input
  read -r input
  echo "$input"
}

os=$(uname -s)

git_user_email=$(git config user.email || true)
git_user_email=${git_user_email:-$GIT_USER_EMAIL}
git_user_email=${git_user_email:-$(prompt 'Git User Email Address: ')}

git_user_name=$(git config user.name || true)
git_user_name=${git_user_name:-$GIT_USER_NAME}
git_user_name=${git_user_name:-$(prompt 'Git User Name: ')}

git_user_signing_key=$(git config user.signingKey || true)
git_user_signing_key=${git_user_signing_key:-$GIT_USER_SIGNING_KEY}
git_user_signing_key=${git_user_signing_key:-$(prompt 'Git User Signing Key: ')}

/usr/bin/env bash stage1/install.sh
/usr/bin/env bash stage2/install.sh
/usr/bin/env bash stage3/install.sh

if [[ -z "$git_user_email" ]]; then
  echo 'Skip setting Git user email address' >&2
else
  git config --global user.email "$git_user_email"
fi

if [[ -z "$git_user_name" ]]; then
  echo 'Skip setting Git user name' >&2
else
  git config --global user.name "$git_user_name"
fi

if [[ -z "$git_user_signing_key" ]]; then
  echo 'Skip setting Git user signing key' >&2
else
  git config --global user.signingKey "$git_user_signing_key"
  git config --global commit.gpgsign true
fi

if [[ "$os" = Darwin ]] && ! grep pinentry-program "$HOME/.gnupg/gpg-agent.conf"; then
  echo 'pinentry-program /usr/local/bin/pinentry-mac' >>"$HOME/.gnupg/gpg-agent.conf"
fi
