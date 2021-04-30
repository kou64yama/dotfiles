#!/usr/bin/env bash

set -eo pipefail

dirname=${0%/*}

brew bundle -v --file "$dirname/Brewfile" --no-lock
