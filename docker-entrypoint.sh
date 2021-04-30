#!/bin/sh

set -e

anyenv install --init

exec "$@"
