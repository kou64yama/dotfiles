# vim: tabstop=2 shiftwidth=2 expandtab

if [[ "$TERM" == dumb ]]; then
  PS1='$ '
  return
fi

# if [[ $- == *l* ]]; then
#   shell=$(which zsh)
#   if [[ "$shell" != "$SHELL" ]]; then
#     SHELL=$shell
#     exec "$SHELL" -l
#   fi
# fi

bindkey -e

source ~/.zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug 'dracula/zsh', as:theme

zplug 'zsh-users/zaw'
zplug 'zsh-users/zsh-completions'
zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-history-substring-search'
zplug 'zsh-users/zsh-syntax-highlighting', defer:2

zplug 'b4b4r07/enhancd', use:init.sh

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo
    zplug install
  fi
fi

zplug load --verbose

if zplug check 'zsh-users/zaw'; then
  bindkey '^R' zaw-history
fi

if zplug check 'zsh-users/zsh-history-substring-search'; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down

  bindkey -M emacs '^P' history-substring-search-up
  bindkey -M emacs '^N' history-substring-search-down

  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

if zplug check 'b4b4r07/enhancd'; then
  export ENHANCD_FILTER=fzf-tmux
fi

# color
case $TERM in
*color*) color='yes' ;;
*) color='no' ;;
esac

# aliases
if command -v exa >/dev/null 2>&1; then
  alias ls='exa'
elif [[ "$color" = yes ]]; then
  if ls --color >/dev/null 2>&1; then
    alias ls='ls --color=auto'
  elif ls -G >/dev/null 2>&1; then
    alias ls='ls -G'
  fi
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='grep'
elif [[ "$color" = yes ]]; then
  alias grep='grep --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style plain --paging never'
fi

# history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space

# completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# zstyle ':completion:*:processes' command 'ps -au$USER'
# zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=36=31'
# zstyle ':completion:*' completer _expand _complete _ignored
# zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# zstyle ':completion:*' menu select=2
# zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
# zstyle ':completion:*:descriptions' format '%U%F{yellow}%d%f%u'

if [[ -d "$HOME/.zsh" ]]; then
  for i in "$HOME/.zsh/"*.zsh; do
    if [[ -f "$i" ]]; then
      source "$i"
    fi
  done
fi
