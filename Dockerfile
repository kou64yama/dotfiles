# base
# ------------------------------------------------------------------------------

ARG VARIANT=20.04
FROM ubuntu:${VARIANT} AS base

LABEL maintainer="Yamada Koji <kou64yama@gmail.com>"

ARG USERNAME=dotfiles
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN apt update \
  && apt install -y --no-install-recommends tzdata language-pack-en \
  && apt autoremove \
  && rm -r /var/lib/apt/lists \
  && groupadd -g ${USER_GID} ${USERNAME} \
  && useradd -lm -s /bin/bash -g ${USER_GID} -u ${USER_UID} ${USERNAME} \
  && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" >>/etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]

ENV TZ=UTC
ENV LANG=en_US.UTF-8

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# stage1
# ------------------------------------------------------------------------------
#
# - Install Homebrew dependencies
# - Install Homebrew

FROM base AS stage1

USER root
RUN apt update
RUN apt install -y --no-install-recommends \
  curl \
  ca-certificates \
  sudo \
  git \
  build-essential \
  unzip \
  zlib1g-dev
RUN update-ca-certificates

USER ${USERNAME}
RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

# stage2
# ------------------------------------------------------------------------------
#
# - Install essential packages and settings

FROM stage1 AS stage2

WORKDIR /workspace
COPY --chown=${USERNAME}:${USERNAME} stage2 .
RUN brew bundle -v --no-lock --file ./Brewfile
RUN ./install.sh

USER root
RUN rm -r /workspace

ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# stage3
# ------------------------------------------------------------------------------
#
# - Install extra packages and settings

FROM stage2 AS stage3

WORKDIR /workspace
COPY --chown=${USERNAME}:${USERNAME} stage3 .
RUN brew bundle -v --no-lock --file ./Brewfile
RUN ./install.sh

USER root
RUN rm -r /workspace

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# slim
# ------------------------------------------------------------------------------

FROM stage3 AS slim

RUN rm -r /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*
RUN rm -r /home/${USERNAME}/.cache

# runtime
# ------------------------------------------------------------------------------

FROM base

COPY --from=slim --chown=${USERNAME}:${USERNAME} /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew
COPY --from=slim --chown=${USERNAME}:${USERNAME} /home/${USERNAME} /home/${USERNAME}

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH
