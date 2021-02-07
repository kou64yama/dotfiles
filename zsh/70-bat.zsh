# shellcheck disable=SC2148

if command -v bat >/dev/null 2>&1; then
  alias cat='bat --style plain --paging never'
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
