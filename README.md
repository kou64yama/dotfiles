# dotfiles

Personal configuration files for Git, Zsh, tmux, and Neovim.

## Included tools

- Git: global `.gitconfig`
- Zsh: `.zshrc` and Zim modules configured through `.zimrc`
- tmux: TPM, tmux-sensible, tmux-pain-control, tmux-prefix-highlight, and the Dracula theme
- Neovim: Lua-based configuration bootstrapped with lazy.nvim

## Prerequisites

The installer requires:

- `bash`
- `curl`
- `patch`

To use all installed configuration files, install the corresponding tools as needed:
`git`, `zsh`, `tmux`, and `neovim`.

## Installation

```bash
bash -c "$(curl -fsSL https://github.com/kou64yama/dotfiles/raw/main/bootstrap.sh)"
```

The bootstrap script downloads this repository and runs `install.sh -i`, which
shows the generated patch before applying it to your home directory.

## Docker

Pull the prebuilt image from GitHub Container Registry:

```bash
docker pull ghcr.io/kou64yama/dotfiles:latest
```

Start an interactive shell:

```bash
docker run --rm -it ghcr.io/kou64yama/dotfiles:latest
```

## Customization

Source files live under `files/<tool>/`, such as `files/git/`,
`files/zsh/`, `files/tmux/`, and `files/nvim/`.

To add or change an installed file:

1. Edit or add the source file under `files/<tool>/`.
2. Add or update its entry in `manifest.txt` using the format
   `mode destination source`.
3. Test the installer against a temporary home directory:

   ```bash
   HOME="$(mktemp -d)" ./install.sh
   ```

For local installation, preview the patch before applying it:

```bash
./install.sh -i
```
