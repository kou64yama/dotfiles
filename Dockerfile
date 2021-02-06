FROM homebrew/brew:3.0.0

WORKDIR /work
COPY . .
RUN apt-get update \
  && apt-get install -y --no-install-recommends zsh \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/* \
  && bash /work/install.sh \
  && rm -rf /work

WORKDIR /
CMD [ "/bin/zsh", "-l" ]
