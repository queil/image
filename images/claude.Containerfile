FROM docker.io/alpine:latest

USER root

RUN adduser -D -u 7222 -g claude claude
RUN apk add libgcc libstdc++ ripgrep bash curl jq git delta fd tree micro ca-certificates unzip

RUN curl -sSL https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh | bash -s -- --install-dir /usr/lib/dotnet

USER claude
ENV ZELLIJ_VER=0.44.0

RUN curl -sSL "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VER}/zellij-no-web-aarch64-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz && \
    tar -zxvf /tmp/zellij.tar.gz -C /tmp && mkdir -p ~/.local/bin && mv /tmp/zellij ~/.local/bin/ && chmod +x ~/.local/bin/zellij && rm /tmp/zellij.tar.gz

RUN curl -fsSL https://claude.ai/install.sh | bash
# bun for plugins
RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/home/claude/.local/bin:/home/claude/.bun/bin:$PATH"
