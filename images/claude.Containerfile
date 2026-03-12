FROM docker.io/alpine:latest

USER root
RUN adduser -D -u 7222 -g claude claude
RUN apk add libgcc libstdc++ ripgrep bash curl jq git fd tree dotnet10-sdk
USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/claude/.local/bin:$PATH"
