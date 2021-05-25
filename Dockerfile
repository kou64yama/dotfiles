# syntax=docker/dockerfile:1.2

FROM ubuntu:20.04 AS base

RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives \
  apt update \
  && apt install -y --no-install-recommends tzdata language-pack-en \
  && apt install -y --no-install-recommends curl ca-certificates sudo git build-essential unzip zlib1g-dev \
  && update-ca-certificates \
  && groupadd -g 1000 linuxbrew \
  && useradd -l -m -s /bin/bash -u 1000 -g 1000 linuxbrew \
  && echo "linuxbrew ALL=(root) NOPASSWD:ALL" >/etc/sudoers.d/linuxbrew \
  && chmod 0440 /etc/sudoers.d/linuxbrew \
  && apt autoremove

FROM base as builder

USER linuxbrew
WORKDIR /workspace

RUN \
  --mount=type=cache,target=/home/linuxbrew/.cache/Homebrew,uid=1000,gid=1000 \
  --mount=type=cache,target=/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps,uid=1000,gid=1000 \
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
ENV PATH=/home/linuxbrew/.linuxbrew/bin:$PATH

COPY stage1 stage1
RUN \
  --mount=type=cache,target=/home/linuxbrew/.cache/Homebrew,uid=1000,gid=1000 \
  --mount=type=cache,target=/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps,uid=1000,gid=1000 \
  bash -x stage1/install.sh

COPY stage2 stage2
RUN bash -x stage2/install.sh

COPY stage3 stage3
RUN bash -x stage3/install.sh

FROM base

COPY --from=builder --chown=linuxbrew:linuxbrew /home/linuxbrew /home/linuxbrew

USER linuxbrew

ENV HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
ENV HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
ENV HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH:+:$PATH}
ENV MANPATH=/home/linuxbrew/.linuxbrew/share/man${MANPATH:+:$MANPATH}
ENV INFOPATH=/home/linuxbrew/.linuxbrew/share/info${INFOPATH:+:$INFOPATH}
ENV TZ=UTC
ENV LANG=en_US.UTF-8
ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh

WORKDIR /home/linuxbrew
CMD [ "/home/linuxbrew/.linuxbrew/bin/zsh", "-l" ]
