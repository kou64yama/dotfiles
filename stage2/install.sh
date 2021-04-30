#!/usr/bin/env bash

set -eo pipefail

if ! [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  if [[ -f "$HOME/.bashrc" ]]; then
    cp "$HOME/.bashrc" "$HOME/.bashrc.bak"
  fi
  if [[ -f "$HOME/.zshrc" ]]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  curl -s "https://get.sdkman.io" | bash

  if [[ -f "$HOME/.bashrc.bak" ]]; then
    mv "$HOME/.bashrc.bak" "$HOME/.bashrc"
  else
    rm -f "$HOME/.bashrc"
  fi
  if [[ -f "$HOME/.zshrc.bak" ]]; then
    mv "$HOME/.zshrc.bak" "$HOME/.zshrc"
  else
    rm -f "$HOME/.zshrc"
  fi
fi
