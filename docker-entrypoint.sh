#!/bin/sh

set -e

print_usage() {
  cat <<EOF >&2
Usage: $0 [OPTIONS]
       $0 [OPTIONS] [--] COMMAND

Options:
  -h, --help
    Print this help message.
  -s, --shell SHELL
    Set the shell to use.
EOF
}

error() {
  echo "$0: $*" >&2
}

shell=${SHELL:-/bin/bash}

while [ $# -gt 0 ]; do
  case $1 in
  -h | --help)
    shift
    print_usage
    exit 2
    ;;
  -s | --shell)
    test $# -ge 2 || (error "missing argument for $1" && print_usage && exit 2)
    shell=$2
    shift 2
    ;;
  --shell=*)
    shell=${1#*=}
    shift
    ;;
  --)
    shift
    break
    ;;
  --*)
    error "unrecognized option -- $1" && print_usage
    exit 2
    ;;
  -*)
    error "invalid option -- ${1#-}" && print_usage
    exit 2
    ;;
  *)
    break
    ;;
  esac
done

if [ $# -gt 0 ]; then
  exec "$@"
fi

exec "$shell" -l
