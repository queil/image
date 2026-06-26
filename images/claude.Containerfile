FROM docker.io/ubuntu:latest

USER root

RUN useradd -m -u 7222 -c claude -s /bin/bash claude

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgcc-s1 libstdc++6 ripgrep bash curl jq git git-delta fd-find tree micro ca-certificates unzip nodejs npm && \
    npx --yes playwright install-deps && \
    rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh | bash -s -- --install-dir /usr/lib/dotnet

USER claude

ENV ZELLIJ_VER=0.44.3

RUN curl -sSL "https://github.com/zellij-org/zellij/releases/download/v${ZELLIJ_VER}/zellij-no-web-aarch64-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz && \
    tar -zxvf /tmp/zellij.tar.gz -C /tmp && mkdir -p ~/.local/bin && mv /tmp/zellij ~/.local/bin/ && chmod +x ~/.local/bin/zellij && rm /tmp/zellij.tar.gz

RUN curl -fsSL https://claude.ai/install.sh | bash

# bun for plugins
RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/home/claude/.local/bin:/home/claude/.bun/bin:$PATH"
