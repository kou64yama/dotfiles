#!/usr/bin/env bash

set -eo pipefail

trap 'if [[ -n "$sandbox" ]]; then rm -rf "$sandbox"; fi' EXIT

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
sandbox=$(mktemp -d)
interactive=no

while getopts i OPT; do
  case $OPT in
  i) interactive=yes ;;
  *)
    echo "Usage: $0 [-i]" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

while read -r line; do
  if [[ "$line" =~ ^# ]] || [[ "$line" =~ ^[\ \t]*$ ]]; then
    continue
  fi

  manifest+=("$line")
done <"$script_dir/manifest.txt"

mkdir -p "$sandbox/a"
if [[ -f "$HOME/.local/var/dotfiles.tgz" ]]; then
  tar -xf "$HOME/.local/var/dotfiles.tgz" -C "$sandbox/a"
fi

mkdir -p "$sandbox/b"
for file in "${manifest[@]}"; do
  IFS=' ' read -r mode path src <<<"$file"
  dir=$(dirname "$path")
  if [[ ! -d "$sandbox/b/$dir" ]]; then
    mkdir -p "$sandbox/b/$dir"
  fi
  cp "$script_dir/$src" "$sandbox/b/$path"
  chmod "$mode" "$sandbox/b/$path"
done

if (cd "$sandbox" && diff -uNr a b >"$sandbox/patch.diff"); then
  echo "No diff found." >&2
  exit 0
fi

if [[ "$interactive" = yes ]]; then
  cat "$sandbox/patch.diff" >&2
  echo >&2
  echo -n "Apply? (y/N): " >&2
  read -r REPLY
  echo >&2

  if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
    echo "Aborted." >&2
    exit 1
  fi
fi

(
  cd "$HOME"
  if ! patch --dry-run -s -E -p1 --forward --batch <"$sandbox/patch.diff" >/dev/null 2>&1; then
    echo "Error: Conflicts detected! Cannot apply dotfiles patch cleanly." >&2
    echo "Please resolve the conflicts manually by checking the diff:" >&2
    cat "$sandbox/patch.diff" >&2
    exit 1
  fi
  patch -E -p1 --forward --batch <"$sandbox/patch.diff"
)

tar -cf "$sandbox/dotfiles.tgz" -C "$sandbox/b" .
mkdir -p "$HOME/.local/var"
mv "$sandbox/dotfiles.tgz" "$HOME/.local/var/dotfiles.tgz"
