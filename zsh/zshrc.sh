# ~/.zshrc

# for Emacs Tramp mode.
[[ "$TERM" == "dumb" ]] && PS1='$ ' && return

_tmux_session_cmd() {
    [ ! -z "$TMUX" ] && return
    tmux list-sessions 2> /dev/null |\
        sed -e 's/:/ #/g' -e 's/^/tmux attach -t /g'
    echo 'tmux'
}

_choose_cmd() {
    local i line cmds=() cmdline
    cat $1 | while read line; do
        cmds+=($line)
        i=$((i + 1))
        echo "[$i] $line"
    done
    [ -z "$i" ] && return

    echo
    echo -n 'Choose? ' && read i
    [ -z "$i" ] && return

    cmdline="${cmds[$i]%%#*}"
    [ -z "$cmdline" ] && return

    exec eval $cmdline
}

_choose_cmd <(_tmux_session_cmd)

autoload -U compinit && compinit

source ~/.zplug/zplug

zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zaw"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-completions"

zplug "themes/steeef", from:oh-my-zsh

zplug "plugins/git", from:oh-my-zsh, if:"which git"

if ! zplug check --verbose; then
    echo -n "Install? [y/N]: "
    read -q && echo && zplug install
fi

zplug load --verbose

# cdr
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# bind UP and DOWN arrow keys (compatibility fallback
# for Ubuntu 12.04, Fedora 21, and MacOSX 10.9 users)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

if [ ! -S "$SSH_AUTH_SOCK" ]; then
    export SSH_AUTH_SOCK="$HOME/.ssh/auth"
    ssh-agent -a "$SSH_AUTH_SOCK" > /dev/null 2>&1
fi
