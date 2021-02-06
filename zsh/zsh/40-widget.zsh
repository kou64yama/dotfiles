if zplug check 'b4b4r07/enhancd'; then
  export ENHANCD_FILTER=fzf-tmux
fi

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
