# For Emacs Tramp mode.
[ "$TERM" = "dumb" ] && PS1='$ ' && return

source ~/.zplug/zplug

zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zaw"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"

zplug "themes/steeef", from:oh-my-zsh

if ! zplug check --verbose; then
    echo -n "Install? [y/N]: "
    read -q && echo && zplug install
fi

zplug load

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# bind UP and DOWN arrow keys (compatibility fallback for Ubuntu
# 12.04, Fedora 21, and MacOSX 10.9 users)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
