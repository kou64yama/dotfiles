tap "homebrew/bundle"
tap "homebrew/cask"
tap "homebrew/cask-fonts"
tap "homebrew/core"
tap "homebrew/services"

# Homebrew Core
brew "asdf"
brew "bat"
brew "direnv"
brew "emacs" if !OS.mac?
brew "emojify"
brew "exa"
brew "fd"
brew "fzf"
brew "ghq"
brew "git"
brew "gnupg"
brew "gron"
brew "httpie"
brew "jq"
brew "pinentry-mac" if OS.mac?
brew "ripgrep"
brew "starship"
brew "tig"
brew "tmux"
brew "zip"
brew "zplug"
brew "zsh"

# Homebrew Cask
if OS.mac?
  cask "emacs"
  cask "hyper"
  cask "typora"
  cask "visual-studio-code"
  cask "vivaldi"
end

# Homebrew Cask Fonts
if OS.mac?
  cask "font-anka-coder"
  cask "font-fira-code-nerd-font"
  cask "font-migu-1c"
  cask "font-migu-1m"
  cask "font-migu-1p"
  cask "font-migu-2m"
  cask "font-noto-emoji"
end
