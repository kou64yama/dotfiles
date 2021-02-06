FROM homebrew/brew:3.0.0

WORKDIR /work

COPY . /work
RUN bash /work/install.sh && rm -rf /work

WORKDIR /
ENTRYPOINT [ "/bin/bash", "-l" ]
