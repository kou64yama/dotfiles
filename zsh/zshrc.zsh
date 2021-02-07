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

export ZPLUG_HOME=$HOME/.zplug
source "$(brew --prefix)/opt/zplug/init.zsh"

# zplug packages
for f in $(find "$HOME/.zsh" -maxdepth 1 -type f -name '3[0-9]-*.zsh' | sort); do
  source "$f"
done

if ! zplug check; then
  zplug install
fi

zplug load

# after zplug loaded
for f in $(find "$HOME/.zsh" -maxdepth 1 -type f -name '[4-8][0-9]-*.zsh' | sort); do
  source "$f"
done

bindkey -e
