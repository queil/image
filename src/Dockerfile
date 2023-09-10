FROM registry.fedoraproject.org/fedora-minimal:39 as base

ARG USER=queil
ARG HOME=/home/$USER

# Software

RUN microdnf update -y && \
    microdnf install -y --nodocs --setopt install_weak_deps=0 \
    systemd tar unzip bash-completion git micro jq dnsutils htop which procps-ng \
    podman podman-compose slirp4netns fuse-overlayfs --exclude container-selinux && \
    rpm --setcaps shadow-utils 2>/dev/null

RUN adduser $USER && chown $USER -R $HOME && \
    echo -e "$USER:1:999\n$USER:1001:64535" > /etc/subuid; \
    echo -e "$USER:1:999\n$USER:1001:64535" > /etc/subgid;

COPY containers.conf /etc/containers/containers.conf
COPY podman-containers.conf $HOME/.config/containers/containers.conf

RUN chmod 0755 /usr/bin/newuidmap && chmod 0755 /usr/bin/newgidmap

#Copy & modify the defaults to provide reference if runtime changes needed.
#Changes here are required for running with fuse-overlay storage inside container.
RUN sed -e 's|^#mount_program|mount_program|g' \
           -e '/additionalimage.*/a "/var/lib/shared",' \
           -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
           /usr/share/containers/storage.conf \
           > /etc/containers/storage.conf

RUN mkdir -p /home/$USER/.local/share/containers && \
    chown $USER:$USER -R /home/$USER && \
    chmod 644 /etc/containers/containers.conf

# Note VOLUME options must always happen after the chown call above
# RUN commands can not modify existing volumes
VOLUME /var/lib/containers
VOLUME /home/$USER/.local/share/containers

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers \
             /var/lib/shared/vfs-images \
             /var/lib/shared/vfs-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock && \
    touch /var/lib/shared/vfs-images/images.lock && \
    touch /var/lib/shared/vfs-layers/layers.lock

ENV _CONTAINERS_USERNS_CONFIGURED=""

RUN curl -sSL https://starship.rs/install.sh -o ./install.sh && \
    chmod +x ./install.sh && ./install.sh --yes && rm ./install.sh

# User setup

WORKDIR $HOME
USER $USER

RUN systemctl --user enable podman.socket

RUN mkdir -p $HOME/.local/bin

RUN curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o /tmp/vscode-server-linux-x64.tar.gz && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C /tmp && \
    export VSCODE_GIT_HASH=$(cat /tmp/vscode/product.json | jq -r .commit) && \
    mkdir -p $HOME/.vscode-server/bin/$VSCODE_GIT_HASH && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $HOME/.vscode-server/bin/$VSCODE_GIT_HASH --strip 1 && \
    touch $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/0 && \
    rm /tmp/vscode-server-linux-x64.tar.gz

USER root
RUN ln -s $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/bin/code-server /usr/bin/code-server
USER $USER

# global vscode extensions

RUN code-server --install-extension streetsidesoftware.code-spell-checker && \
    code-server --install-extension luxcium.pop-n-lock-theme-vscode

COPY --chown=$USER ./home/queil/ $HOME/

RUN echo '. $HOME/.custom.sh' >> .bashrc

# VARIANT - DOTNET

FROM ghcr.io/queil/image:latest as dotnet-base

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN code-server --install-extension Ionide.Ionide-fsharp

FROM dotnet-base as dotnet-6

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 dotnet-sdk-6.0 && microdnf clean all && rm -rf /var/cache/yum
USER queil

FROM ghcr.io/queil/image:latest as dotnet-7

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 dotnet-sdk-7.0 && microdnf clean all && rm -rf /var/cache/yum
USER queil

# VARIANT - RUST

FROM ghcr.io/queil/image:latest as rust

USER root

RUN microdnf install -y --nodocs --setopt install_weak_deps=0 gcc && \
    microdnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

USER queil

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="${PATH}:${HOME}/.cargo/bin"

RUN code-server --install-extension rust-lang.rust-analyzer && \
    code-server --install-extension vadimcn.vscode-lldb

# VARIANT - PYTHON

FROM ghcr.io/queil/image:latest as python

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 poetry && microdnf clean all && rm -rf /var/cache/yum
USER queil

RUN code-server --install-extension ms-python.python

# VARIANT - DEVOPS

FROM ghcr.io/queil/image:latest as devops

ARG SOPS_VER=3.7.3
ARG AWS_VAULT_VER=7.2.0

ENV AWS_VAULT_BACKEND=file
ENV AWS_EC2_METADATA_DISABLED=true

USER root

RUN curl -sSL https://github.com/mozilla/sops/releases/download/v${SOPS_VER}/sops-v${SOPS_VER}.linux.amd64 -o /usr/bin/sops && \
    chmod +x /usr/bin/sops && \
    curl -sSL https://github.com/99designs/aws-vault/releases/download/v${AWS_VAULT_VER}/aws-vault-linux-amd64 -o /usr/bin/aws-vault && \
    chmod +x /usr/bin/aws-vault && \
    curl -sSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm ./awscliv2.zip && rm ./aws -r

RUN microdnf install -y --nodocs --setopt install_weak_deps=0 docker-compose && microdnf clean all && rm -rf /var/cache/yum

USER queil
