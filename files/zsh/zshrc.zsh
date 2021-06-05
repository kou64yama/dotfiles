debug() {
  if [[ "$-" = *i* ]]; then
    echo "$@" >&2
  fi
}

# Load the level 0 scripts (at any time)
for f in $(find "$HOME/.zsh.d" -maxdepth 1 -type f -name '0[0-9]-*.zsh' | sort); do
  debug "Loading $f"
  source "$f"
done

# for GNU Emacs tramp-mode
if [[ "$TERM" == dumb ]]; then
  PS1='$ '
  return
fi

# Load the level 1 scripts (before zplug initializing)
for f in $(find "$HOME/.zsh.d" -maxdepth 1 -type f -name '1[0-9]-*.zsh' | sort); do
  debug "Loading $f"
  source "$f"
done

# Load zplug
export ZPLUG_HOME=$HOME/.zplug
source "$(brew --prefix)/opt/zplug/init.zsh"

zplug 'zsh-users/zaw'
zplug 'zsh-users/zsh-completions'
zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-history-substring-search'
zplug 'zsh-users/zsh-syntax-highlighting', defer:2

zplug 'b4b4r07/enhancd', use:init.sh

# Install zplug plugins
if ! zplug check; then
  zplug install
fi
zplug load

# Load the level 2-9 scripts (after zplug loaded)
for f in $(find "$HOME/.zsh.d" -maxdepth 1 -type f -name '[2-9][0-9]-*.zsh' | sort); do
  debug "Loading $f"
  source "$f"
done
