# vim: tabstop=2 shiftwidth=2 expandtab

if [[ $TERM = "dumb" ]]; then
  PS1="$ "
  return
fi

if [[ "x$TMUX" = x ]] && which tmux >/dev/null 2>&1; then
  cmd=($cmd 'tmux # new session')
  tmux list-sessions 2>/dev/null | while read i; do
    cmd=($cmd "tmux attach-session -t ${i%%:*} # ${i#*: }")
  done
fi

if [[ ${#cmd} -gt 0 ]]; then
  for ((i = 1; i <= ${#cmd}; i++)); do
    echo "[$i] ${cmd[i]}"
  done

  echo -n "Choose command: " 1>&2
  read i
  cmd=${cmd[i]}
  cmd=${cmd%%#*}
  
  if [[ x$cmd != x ]]; then
    exec eval "$cmd"
  fi

  unset cmd i
fi

source ~/.zplug/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug 'dracula/zsh', as:theme

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
#zplug 'direnv/direnv', \
#  from:gh-r, \
#  as:command, \
#  rename-to:direnv

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load --verbose

# color
case $TERM in
  *color*) color='yes';;
  *) color='no';;
esac

if [[ $color == yes ]]; then
  alias ls='ls --color=auto'
fi

# history
export HISTFILE=$HOME/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000

setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space

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

if zplug check 'direnv/direnv'; then
  eval "$(direnv hook zsh)"
fi
