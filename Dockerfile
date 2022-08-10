# syntax=docker/dockerfile:1

ARG VARIANT=20.04
FROM ubuntu:${VARIANT} AS base

ARG USERNAME=dotfiles
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN \
  --mount=type=cache,target=/var/lib/apt/lists \
  --mount=type=cache,target=/var/cache/apt/archives/ \
  apt update \
  && apt install -y --no-install-recommends tzdata language-pack-en sudo \
  && apt install -y --no-install-recommends curl ca-certificates git patch zsh file unzip \
  && apt autoremove \
  && groupadd -g ${USER_GID} ${USERNAME} \
  && useradd -lm -s /bin/bash -g ${USER_GID} -u ${USER_UID} ${USERNAME} \
  && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" >>/etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

ENV ZI_HOME=/home/zi

FROM base AS builder

WORKDIR /workspace
COPY . .
RUN sh -c "$(curl -fsSL https://git.io/get-zi)" -- -i skip

USER ${USERNAME}
RUN ./install.sh && mkdir -p /home/${USERNAME}/.zi/polaris/bin

FROM base

LABEL maintainer=kou64yama@gmail.com

COPY --chown=${USERNAME}:${USERNAME} --from=builder /home/zi /home/zi
COPY --chown=${USERNAME}:${USERNAME} --from=builder /home/${USERNAME} /home/${USERNAME}

WORKDIR /home/${USERNAME}
USER ${USERNAME}

ENV TZ=UTC
ENV LANG=en_US.UTF-8
CMD [ "/usr/bin/zsh", "-l" ]
