# shellcheck disable=SC2148

# swap shell
if shell=$(command -v zsh) && [[ "$shell" != "$SHELL" ]]; then
  SHELL=$shell exec "$shell" -l
fi

mkdir -p "$HOME/.zsh"

# bootstrap
for f in $(find "$HOME/.zsh" -maxdepth 1 -type f -name '1[0-9]-*.zsh' | sort); do
  source "$f"
done

# for GNU Emacs tramp-mode
if [[ "$TERM" == dumb ]]; then
  PS1='$ '
  return
fi

# before zplug init
for f in $(find "$HOME/.zsh" -maxdepth 1 -type f -name '2[0-9]-*.zsh' | sort); do
  source "$f"
done

if ! [[ -f "$HOME/.zplug/init.zsh" ]]; then
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi
source "$HOME/.zplug/init.zsh"

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# zplug packages
for f in $(find "$HOME/.zsh" -maxdepth 1 -type f -name '3[0-9]-*.zsh' | sort); do
  source "$f"
done

if ! zplug check; then
  printf "Install? [y/N]: "
  if read -q; then
    echo
    zplug install
  fi
fi

zplug load

# after zplug loaded
for f in $(find "$HOME/.zsh" -maxdepth 1 -type f -name '[4-8][0-9]-*.zsh' | sort); do
  source "$f"
done

bindkey -e
