FROM ubuntu:20.04

ARG USER=user
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl sudo git ca-certificates build-essential \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-ca-certificates \
  && useradd -m -s /bin/bash "${USER}" \
  && echo "${USER} ALL=(root) NOPASSWD:ALL" >"/etc/sudoers.d/${USER}" \
  && chmod 0440 /etc/sudoers.d/user

USER "${USER}"
WORKDIR "/home/${USER}/work"

COPY --chown="${USER}:${USER}" . .
RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash \
  && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>"/home/${USER}/.profile" \
  && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" \
  && DOTFILES=$PWD bash install.sh \
  && rm -rf "/home/${USER}/work" "$(brew --cache)"

WORKDIR "/home/${USER}"
CMD [ "/home/linuxbrew/.linuxbrew/bin/zsh", "-l" ]
