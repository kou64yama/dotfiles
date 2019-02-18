# vim: tabstop=2 shiftwidth=2 expandtab

if [[ $TERM == "dumb" ]]; then
  PS1="$ "
  return
fi

if [[ "x$TMUX" == x ]] && which tmux >/dev/null 2>&1; then
  cmd=($cmd 'tmux # new session')
  tmux list-sessions 2>/dev/null | while read i; do
    cmd=($cmd "tmux attach-session -t ${i%%:*} # ${i#*: }")
  done
fi

if [[ ${#cmd} > 0 ]]; then
  for ((i = 1; i <= ${#cmd}; i++)); do
    echo "[$i] ${cmd[i]}" 1>&2
  done

  echo
  echo -n "Choose startup command: " 1>&2
  read i
  cmd=${cmd[i]}
  cmd=${cmd%%#*}

  if [[ x$cmd != x ]]; then
    exec eval "$cmd"
  fi
  unset i
fi

unset cmd

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

zplug 'junegunn/fzf-bin', \
  from:gh-r, \
  as:command, \
  rename-to:fzf
zplug 'junegunn/fzf', \
  as:command, \
  use:bin/fzf-tmux
zplug 'stedolan/jq', \
  from:gh-r, \
  as:command, \
  rename-to:jq

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
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
  *color*) color='yes';;
  *) color='no';;
esac

if [[ $color == yes ]]; then
  if ls --color >/dev/null 2>&1; then
    alias ls='ls --color=auto'
  fi

  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
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
zstyle ':completion:*:processes' command 'ps -au$USER'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=36=31'
zstyle ':completion:*' completer _expand _complete _ignored
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*:descriptions' format '%U%F{yellow}%d%f%u'

__fzf-history() {
  LBUFFER=$(fc -l 1 | fzf +s --tac | sed "s/ *[0-9]* *//")
}

gitmoji() {
  if [[ ! -f "$HOME/.gitmojis.json" ]]; then
    curl -sL -o "$HOME/.gitmojis.json" \
      https://raw.githubusercontent.com/carloscuesta/gitmoji/master/src/data/gitmojis.json
  fi

  local code=$(cat ~/.gitmojis.json \
    | jq -r '.gitmojis | map(.code + " " + .description)[]' \
    | fzf-tmux \
    | sed -e 's/.*\(:.\+:\).*/\1/')
  LBUFFER="${LBUFFER}${code}"
}

zle -N gitmoji
bindkey '^Xcc' gitmoji
zle -N __fzf-history
bindkey '^R' __fzf-history

if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"
fi
