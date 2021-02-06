FROM homebrew/brew:3.0.0

WORKDIR /work
COPY . .
RUN DOTFILES=$PWD bash /work/install.sh \
  && brew autoremove \
  && rm -rf /work "$(brew --cache)"

WORKDIR /
CMD [ "/home/linuxbrew/.linuxbrew/bin/zsh", "-l" ]
