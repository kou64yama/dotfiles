FROM ubuntu:24.04 AS builder

ARG TARGETARCH
ARG MISE_VERSION=2026.6.6
ARG MISE_SHA256_AMD64=b8c25ad5e1c178bb7ba1e0fca9066153f8ef1b28bf5a8456c20a8acd2522e556
ARG MISE_SHA256_ARM64=e3482fc5dde76502c1714b85963da411698436f06fefef7b6f0ee16fd00136a0

RUN --mount=type=cache,target=/var/lib/apt/lists --mount=type=cache,target=/var/cache/apt/archives,sharing=locked \
  apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl patch

WORKDIR /workspace

COPY install.sh ./
COPY files/ ./files/

ENV HOME=/etc/skel
RUN set -eu; \
  case "${TARGETARCH}" in \
    amd64) mise_arch=x64; mise_sha=${MISE_SHA256_AMD64} ;; \
    arm64) mise_arch=arm64; mise_sha=${MISE_SHA256_ARM64} ;; \
    *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  mise_tag=v${MISE_VERSION}; \
  mkdir -p /etc/skel/.local/bin; \
  curl -fsSL "https://github.com/jdx/mise/releases/download/${mise_tag}/mise-${mise_tag}-linux-${mise_arch}" -o /etc/skel/.local/bin/mise; \
  echo "${mise_sha}  /etc/skel/.local/bin/mise" | sha256sum -c -; \
  chmod 0755 /etc/skel/.local/bin/mise; \
  test "$(/etc/skel/.local/bin/mise --version | awk '{print $1}')" = "${MISE_VERSION}"
RUN yes | ./install.sh
RUN echo skip_global_compinit=1 >> /etc/skel/.zshenv

FROM ubuntu:24.04

ARG PACKAGE_LIST='\
  git \
  neovim \
  tmux \
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
