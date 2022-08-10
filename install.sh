#!/usr/bin/env bash

set -eo pipefail

prefix=${PREFIX:-$HOME}
dotfiles_home=${DOTFILES_HOME:-$HOME/.dotfiles}
work_dir=$dotfiles_home/work
history_dir=$dotfiles_home/history
section=
interactive=
patch_file="$history_dir"/"$(date +%s | xargs printf %016x)".patch

inf() {
  echo "$*" >&2
}

err() {
  echo "error: $*" >&2
}

begin() {
  if [[ -n "$section" ]]; then
    printf '\e[32;1m==> %s ... OK \e[m\n' "$section" >&2
  fi

  section=$1
  printf '\e[34;1m==> %s ...\e[m\n' "$section" >&2
}

failure() {
  if [[ -n "$section" ]]; then
    printf '\e[31;1m==> %s ... Failed \e[m\n' "$section" >&2
  fi
  section=
}

success() {
  if [[ -n "$section" ]]; then
    printf '\e[32;1m==> %s ... OK \e[m\n' "$section" >&2
  fi
  section=
}

dotinst() {
  cp "$2" "$work_dir"/b/"$1"
  if [[ ! -f "$work_dir"/a/"$1" ]] && [[ -f "$prefix"/"$1" ]]; then
    cp "$prefix"/"$1" "$work_dir"/a/"$1"
  fi
}

while getopts i OPT; do
  case $OPT in
  i) interactive=yes ;;
  *) ;;
  esac
done
shift $((OPTIND - 1))

mkdir -p "$dotfiles_home" "$history_dir"

if ! mkdir "$work_dir" 2>/dev/null; then
  err "directory '$work_dir' already exists"
  cat >&2 <<EOF
Another process is currently installing dotfiles. If not, delete the
'$work_dir' and re-run.
EOF
  exit 1
fi
trap 'rm -rf "$work_dir"; success' EXIT

begin 'Installing ZI' && {
  sh -c "$(curl -fsSL https://git.io/get-zi)" -- -i skip
}

begin 'Restoring current dotfiles' && {
  mkdir -p "$work_dir"/a
  if [[ -f "$dotfiles_home"/current.tgz ]]; then
    inf "Extract '$dotfiles_home/current.tgz' to '$work_dir/a'."
    tar -xf "$dotfiles_home"/current.tgz -C "$work_dir"/a
  else
    inf "No '$dotfiles_home/current.tgz' exists."
  fi
}

begin 'Installing dotfiles into the sandbox' && {
  mkdir -p "$work_dir"/b

  dotinst .zshrc files/zshrc.zsh
  dotinst .gitconfig files/gitconfig.ini
}

begin 'Applying patch' && {
  if (cd "$work_dir" && diff -urN a b) >"$work_dir"/diff.patch; then
    inf 'No diff.'
    success
    exit 0
  fi

  cat "$work_dir"/diff.patch >&2

  if [[ "$interactive" = yes ]]; then
    echo -n 'Apply? [y/N]: ' >&2
    read -n1 -r ans
    echo >&2
    if [[ "$ans" != y ]]; then
      failure
      exit 1
    fi
  fi

  if ! patch --dry-run -p1 -uEN -d "$prefix" <"$work_dir"/diff.patch; then
    failure
    exit 1
  fi

  patch -p1 -uEN -d "$prefix" <"$work_dir"/diff.patch

  tar -cf "$dotfiles_home"/current.tgz -C "$work_dir"/b .
  cp "$work_dir"/diff.patch "$patch_file"
  inf "This patch is saved into '$patch_file'."

  success
}

cat >&2 <<EOF

The following command reverts this patch:

  $ patch -p1 -uER -d '$HOME' < '$patch_file'

Bye!
EOF
