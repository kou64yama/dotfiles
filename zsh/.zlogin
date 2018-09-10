if [[ ! $SHELL =~ ".*/zsh$" ]] && zsh=$(which zsh); then
  SHELL=$zsh
fi
