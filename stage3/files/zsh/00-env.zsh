eval "$(direnv hook zsh)"
eval "$(anyenv init - zsh)"

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

PATH="$HOME/bin:$HOME/go/bin${PATH:+:$PATH}"
