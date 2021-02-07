FROM homebrew/brew:3.0.0 AS builder

USER linuxbrew
COPY --chown=linuxbrew:linuxbrew Brewfile /home/linuxbrew/.Brewfile
RUN brew bundle -v --global && rm -rf "$(brew --cache)"

ARG USER=kou64yama
USER root
RUN useradd -U -m "${USER}"

USER "${USER}"
COPY --chown="${USER}:${USER}" . "/home/${USER}/work"
WORKDIR "/home/${USER}/work"
RUN DOTFILES=$PWD DOTFILES_NO_INSTALL=1 bash install.sh && rm -rf "/home/${USER}/work"

WORKDIR "/home/${USER}"
ENV LANG=en_US.UTF-8
CMD [ "/home/linuxbrew/.linuxbrew/bin/zsh", "-l" ]
