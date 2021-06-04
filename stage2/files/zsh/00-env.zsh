source "$(brew --prefix asdf)/asdf.sh"

eval "$(direnv hook zsh)"

PATH="$HOME/bin${PATH:+:$PATH}"
