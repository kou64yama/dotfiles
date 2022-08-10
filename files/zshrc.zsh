source "${ZI_HOME:-$HOME/.zi}"/bin/zi.zsh

zi light-mode \
  for z-shell/z-a-meta-plugins \
  @annexes

zi lucid light-mode for as'null' from'gh-r' \
  atclone'
    ./starship init zsh > init.zsh;
    ./starship completions zsh > _starship' \
  atpull'%atclone' \
  sbin'starship' \
  src'init.zsh' \
  starship/starship

zi wait lucid light-mode for \
  z-shell/{F-Sy-H,H-S-MW} \
  atload'_zsh_autosuggest_start' zsh-users/zsh-autosuggestions \
  blockf atpull'zi creinstall -q .' zsh-users/zsh-completions

zi wait lucid light-mode for as'null' from'gh-r' \
  atclone'mkdir -p $ZPFX/{bin,man/man1}' \
  atpull'%atclone' \
  dl'
    https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh -> _fzf_completion;
    https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh -> key-bindings.zsh;
    https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf-tmux.1 -> $ZPFX/man/man1/fzf-tmux.1;
    https://raw.githubusercontent.com/junegunn/fzf/master/man/man1/fzf.1 -> $ZPFX/man/man1/fzf.1' \
  sbin'fzf' \
  src'key-bindings.zsh' \
  junegunn/fzf

zi wait lucid light-mode for as'null' from'gh-r' \
  mv'direnv* -> direnv' \
  atclone'./direnv hook zsh > zhook.zsh' \
  atpull'%atclone' \
  sbin'direnv' \
  src'zhook.zsh' \
  direnv/direnv

zi wait lucid light-mode for as'null' from'gh-r' \
  atclone'
    ln -s completions/_zoxide -> _zoxide;
    cp man/man1/*.1 $ZI[MAN_DIR]/man1;
    ./zoxide init zsh --cmd x > init.zsh' \
  atpull'%atclone' \
  sbin'zoxide' \
  src'init.zsh' \
  ajeetdsouza/zoxide

zi wait lucid light-mode for \
  src'asdf.sh' \
  @asdf-vm/asdf

zicompinit

export HISTSIZE=10000
export SAVEHIST=$HISTSIZE
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space

if command -v exa >/dev/null 2>&1; then
  alias ls='exa -bgh --icons --sort=name --git --time-style=long-iso'
else
  alias ls='ls --color=auto'
fi

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style plain --paging never'
fi

if command -v rg >/dev/null 2>&1; then
  alias grep='rg'
  alias egrep='rg'
  alias fgrep='rg -f'
else
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias fgrep='fgrep --color=auto'
fi

if command -v xh >/dev/null 2>&1; then
  alias http=xh
fi

if command -v emacsclient >/dev/null 2>&1; then
  alias emacs='emacsclient -a "" -c'
fi
