FROM fedora:rawhide as base

ARG USER=queil
ARG GIT_USER=queil
ARG GIT_EMAIL=queil@users.noreply.github.com

ARG HOME=/home/$USER
RUN adduser $USER && chown $USER -R $HOME

# Software

RUN dnf install -y \
    bash-completion \
    git \
    nano \
    bat \
    dnsutils \
    htop \
    podman shadow-utils fuse-overlayfs && \
    dnf clean all && \
    rm -rf /var/cache/yum

RUN chmod 4755 /usr/bin/newuidmap && chmod 4755 /usr/bin/newgidmap

RUN curl -sSL https://starship.rs/install.sh -o ./install.sh && \
    chmod +x ./install.sh && ./install.sh --yes && rm ./install.sh

# User setup

WORKDIR $HOME
USER $USER

ARG VSCODE_GIT_HASH=b7886d7461186a5eac768481578c1d7ca80e2d21

RUN mkdir -p $HOME/.local/bin

RUN curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o /tmp/vscode-server-linux-x64.tar.gz && \
    mkdir -p $HOME/.vscode-server/bin/$VSCODE_GIT_HASH && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $HOME/.vscode-server/bin/$VSCODE_GIT_HASH --strip 1 && \
    touch $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/0 && \
    rm /tmp/vscode-server-linux-x64.tar.gz

RUN git config --global user.name "$GIT_USER" && git config --global user.email "$GIT_EMAIL"

COPY --chown=$USER starship.toml .config/
COPY --chown=$USER .nanorc ./
COPY --chown=$USER .custom.sh ./

RUN mkdir .nano && \
    git clone https://github.com/scopatz/nanorc.git .nano && \
    echo "include ~/.nano/*.nanorc" >> $HOME/.nanorc

RUN ln -s /usr/bin/batcat $HOME/.local/bin/bat
RUN echo '. $HOME/.custom.sh' >> .bashrc

# VARIANT - DOTNET

FROM base as dotnet

USER root

RUN dnf install -y dotnet-sdk-7.0 && dnf clean all && rm -rf /var/cache/yum

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

USER queil

# VARIANT - RUST

FROM base as rust

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="${PATH}:${HOME}/.cargo/bin"
