# Repository Guidelines

## Project Structure & Module Organization

This repository packages personal configuration files and installs them into a target home directory.

- `files/` contains source dotfiles grouped by tool: `git/`, `zsh/`, `tmux/`, and `nvim/`.
- `files/nvim/lua/config/` holds Neovim bootstrap configuration; `lua/plugins/` contains plugin specifications.
- `install.sh` builds a patch from the files listed in its `files` array and applies it to `$HOME`.
- `bootstrap.sh` downloads a selected revision and runs the installer.
- `Dockerfile` creates an Ubuntu image for installation smoke testing.
- `.github/workflows/build.yaml` validates bootstrap installation and multi-platform image builds.

When adding a dotfile, place it under `files/<tool>/` and add its mode, destination, and source path to the manifest in `install.sh`.

## Build, Test, and Development Commands

- `./install.sh -i`: preview the generated patch and confirm before changing the local home directory.
- `HOME="$(mktemp -d)" ./install.sh`: smoke-test installation in an isolated temporary home.
- `docker build -t dotfiles:test .`: reproduce the container build used by CI.
- `bash -n install.sh bootstrap.sh`: check shell syntax without executing the scripts.

There is no separate compile step or unit-test suite. Treat successful isolated installation and Docker build as the primary validation.

## Coding Style & Naming Conventions

Follow `.editorconfig`: UTF-8, LF endings, final newline, trimmed trailing whitespace, and two-space indentation. Shell scripts use Bash, begin with `#!/usr/bin/env bash`, quote expansions, and fail early with `set -eo pipefail`. Keep tool-specific files in lowercase directories and use descriptive Lua module names such as `config/lazy.lua` or `plugins/statusline.lua`.

## Testing Guidelines

Test changes against a temporary `HOME`; do not use a real home directory for unattended checks. For installer changes, verify both a clean installation and conflict handling. For Neovim, Zsh, or tmux changes, start the affected tool after installation when practical.

## Commit & Pull Request Guidelines

Use Conventional Commits with short, imperative subjects, such as `feat(nvim): add statusline plugin`, `fix: handle patch conflicts`, or `ci: update build workflow`. Use `!` or a `BREAKING CHANGE:` footer for incompatible changes. Keep each commit focused. Pull requests should explain user-visible configuration changes, list validation commands, link related issues, and include screenshots only for visual editor or terminal changes.
