FROM docker.io/alpine:latest

USER root
RUN adduser -D -u 7222 -g claude claude
RUN apk add libgcc libstdc++ ripgrep bash curl 
USER claude

RUN curl -fsSL https://claude.ai/install.sh | bash
