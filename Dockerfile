FROM ubuntu:24.04 AS builder

RUN --mount=type=cache,target=/var/lib/apt/lists --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl patch

WORKDIR /workspace

COPY install.sh ./
COPY files/ ./files/

ENV HOME=/etc/skel
RUN curl https://mise.run | sh
RUN yes | ./install.sh
RUN echo skip_global_compinit=1 >> /etc/skel/.zshenv

FROM ubuntu:24.04

ARG PACKAGE_LIST='\
  patch \
  git \
  neovim \
'
RUN --mount=type=cache,target=/var/lib/apt/lists --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl sudo zsh ${PACKAGE_LIST}

COPY --from=builder /etc/skel/ /etc/skel/

ARG USERNAME=dotfiles
ARG USER_UID=3000
ARG USER_GID=${USER_UID}
RUN groupadd -g ${USER_GID} ${USERNAME} \
  && useradd -lm -s /bin/zsh -g ${USER_GID} -u ${USER_UID} ${USERNAME} \
  && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" >>/etc/sudoers.d/${USERNAME} \
  && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
CMD [ "/bin/zsh", "-l" ]
