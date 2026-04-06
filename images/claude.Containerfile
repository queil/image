FROM docker.io/alpine:latest

USER root
RUN adduser -D -u 7222 -g claude claude
RUN apk add libgcc libstdc++ ripgrep bash curl jq git fd tree dotnet10-sdk ca-certificates
ENV ZELLIJ_VER=0.44.0
RUN curl -sSL "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VER}/zellij-no-web-aarch64-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz && \
    tar -zxvf /tmp/zellij.tar.gz -C /tmp && mv "/tmp/zellij" ./.local/bin/ && chmod +x ./.local/bin/zellij && rm /tmp/zellij.tar.gz
USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/claude/.local/bin:$PATH"
