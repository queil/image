FROM ghcr.io/queil/image:latest as rust

USER root

RUN microdnf install -y --nodocs --setopt install_weak_deps=0 gcc && \
    microdnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

USER queil

ARG USER=queil
ARG HOME=/home/$USER

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="${PATH}:${HOME}/.cargo/bin"

RUN code-server --install-extension rust-lang.rust-analyzer && \
    code-server --install-extension vadimcn.vscode-lldb
