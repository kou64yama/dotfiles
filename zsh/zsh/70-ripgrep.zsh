# shellcheck disable=SC2148

if command -v rg >/dev/null 2>&1; then
  alias grep=rg
fi