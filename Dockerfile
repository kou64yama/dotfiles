# syntax=docker/dockerfile:1.2

FROM ubuntu:20.04 AS base

RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives \
  apt update \
  && apt install -y --no-install-recommends tzdata language-pack-en \
  && apt install -y --no-install-recommends curl ca-certificates sudo git build-essential unzip zlib1g-dev \
  && apt autoremove \
  && update-ca-certificates

FROM base AS stage0

ARG USERNAME=dotfiles
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd -g ${USER_GID} ${USERNAME} \
  && useradd -lm -s /bin/bash -g ${USER_GID} -u ${USER_UID} ${USERNAME} \
  && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" >/etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}
USER ${USERNAME}

FROM base AS stage1

RUN groupadd -g 1000 linuxbrew \
  && useradd -lm -s /bin/bash -g 1000 -u 1001 linuxbrew \
  && echo "linuxbrew ALL=(root) NOPASSWD:ALL" >/etc/sudoers.d/linuxbrew \
  && chmod 0440 /etc/sudoers.d/linuxbrew

USER linuxbrew
WORKDIR /workspace

RUN \
  --mount=type=cache,target=/home/linuxbrew/.cache/Homebrew,uid=1000,gid=1000 \
  --mount=type=cache,target=/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps,uid=1000,gid=1000 \
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}

COPY stage1 stage1
RUN \
  --mount=type=cache,target=/home/linuxbrew/.cache/Homebrew,uid=1000,gid=1000 \
  --mount=type=cache,target=/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps,uid=1000,gid=1000 \
  bash -x stage1/install.sh

FROM stage0 AS stage2

COPY --from=stage1 --chown=${USERNAME}:${USERNAME} \
  /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew

COPY stage2 stage2
RUN bash -x stage2/install.sh

FROM stage0

COPY --from=stage1 --chown=${USERNAME}:${USERNAME} \
  /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew
COPY --from=stage2 --chown=${USERNAME}:${USERNAME} \
  /home/${USERNAME} /home/${USERNAME}

ENV HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
ENV HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
ENV HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}
ENV MANPATH=/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}
ENV INFOPATH=/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh

WORKDIR /home/${USERNAME}
CMD [ "/home/linuxbrew/.linuxbrew/bin/zsh", "-l" ]
