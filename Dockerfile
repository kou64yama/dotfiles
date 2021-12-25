# stage1
# ------------------------------------------------------------------------------

ARG VARIANT=20.04
FROM ubuntu:${VARIANT} AS stage1

LABEL maintainer="Yamada Koji <kou64yama@gmail.com>"

RUN apt update \
  && apt install -y --no-install-recommends tzdata language-pack-en \
  && apt install -y --no-install-recommends curl ca-certificates sudo git build-essential unzip zlib1g-dev \
  && apt autoremove \
  && update-ca-certificates \
  && rm -r /var/lib/apt/lists

ENV TZ=UTC
ENV LANG=en_US.UTF-8

COPY docker-entrypoint.sh /
ENTRYPOINT [ "/docker-entrypoint.sh" ]

ARG USERNAME=dotfiles
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
RUN groupadd -g ${USER_GID} ${USERNAME} \
  && useradd -lm -s /bin/bash -g ${USER_GID} -u ${USER_UID} ${USERNAME} \
  && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" >>/etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}

# stage2
# ------------------------------------------------------------------------------

FROM stage1 AS stage2

RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

WORKDIR /workspace

COPY --chown=${USERNAME}:${USERNAME} stage2 .
RUN brew bundle -v --no-lock --file ./Brewfile
RUN ./install.sh

WORKDIR /home/${USERNAME}
RUN sudo rm -r /workspace

ENV SHELL=/home/linuxbrew/.linuxbrew/bin/zsh

# stage3
# ------------------------------------------------------------------------------

FROM stage2 AS stage3

WORKDIR /workspace

COPY --chown=${USERNAME}:${USERNAME} stage3 .
RUN brew bundle -v --no-lock --file ./Brewfile
RUN ./install.sh

WORKDIR /home/${USERNAME}
RUN sudo rm -r /workspace

# slim
# ------------------------------------------------------------------------------

FROM stage3 AS slim

RUN rm -r /home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/*

# runtime
# ------------------------------------------------------------------------------

FROM stage1

COPY --from=slim --chown=${USERNAME}:${USERNAME} /home/linuxbrew/.linuxbrew /home/linuxbrew/.linuxbrew
COPY --from=slim --chown=${USERNAME}:${USERNAME} /home/${USERNAME} /home/${USERNAME}

ENV PATH=/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH

USER ${USERNAME}
WORKDIR /home/${USERNAME}
