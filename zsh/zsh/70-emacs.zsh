# shellcheck disable=SC2148

if [[ -x /Applications/Emacs.app/Contents/MacOS/bin/emacsclient ]]; then
  alias emacs='/Applications/Emacs.app/Contents/MacOS/bin/emacsclient --nw --alternate-editor=""'
fi
