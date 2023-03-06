FROM ubuntu:22.04 as base

ARG USER=queil
ARG GIT_USER=queil
ARG GIT_EMAIL=queil@users.noreply.github.com

ARG HOME=/home/$USER
RUN adduser $USER && groupadd docker && usermod -aG docker $USER && chown $USER -R $HOME

# Software

RUN apt-get update && apt-get install -y \
    gnupg \
    lsb-release \
    bash-completion \
    curl \
    wget \
    git \
    nano \
    bat \
    dnsutils \
    iproute2

RUN mkdir -m 0755 -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin

RUN curl -sSL https://starship.rs/install.sh -o ./install.sh && \
    chmod +x ./install.sh && ./install.sh --yes && rm ./install.sh

# User setup

WORKDIR $HOME
USER $USER

ARG VSCODE_GIT_HASH=441438abd1ac652551dbe4d408dfcec8a499b8bf

RUN mkdir -p $HOME/.local/bin

RUN curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o /tmp/vscode-server-linux-x64.tar.gz && \
    mkdir -p $HOME/.vscode-server/bin/$VSCODE_GIT_HASH && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $HOME/.vscode-server/bin/$VSCODE_GIT_HASH --strip 1 && \
    touch $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/0 && \
    rm /tmp/vscode-server-linux-x64.tar.gz


ARG ROOZ_VERSION=0.8.0
RUN curl -sSL https://github.com/queil/rooz/releases/download/v${ROOZ_VERSION}/rooz -o $HOME/.local/bin/rooz && chmod +x $HOME/.local/bin/rooz

RUN git config --global user.name "$GIT_USER" && git config --global user.email "$GIT_EMAIL"

COPY --chown=$USER starship.toml .config/
COPY --chown=$USER .nanorc ./

RUN mkdir .nano && \
    git clone https://github.com/scopatz/nanorc.git .nano && \
    echo "include ~/.nano/*.nanorc" >> $HOME/.nanorc

RUN ln -s /usr/bin/batcat $HOME/.local/bin/bat

# bashrc setup
RUN echo 'eval "$(starship init bash)"' >> .bashrc && \
    echo 'export CONTAINER_NAME=$(docker ps -f ID=$(hostname) --format "{{.Names}}")' >> .bashrc && \
    echo 'PATH=$HOME/.local/bin:$PATH' >> .bashrc

ARG IMAGE_VERSION
ENV ROOZ_IMAGE=ghcr.io/queil/image:$IMAGE_VERSION
ENV ROOZ_SHELL=bash
ENV ROOZ_USER=$USER

# VARIANT - DOTNET

FROM base as dotnet

USER root

RUN wget https://packages.microsoft.com/config/ubuntu/22.10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
     dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb

RUN apt-get update && apt-get install -y dotnet-sdk-7.0

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true

USER queil

# VARIANT - RUST

FROM base as rust

USER root
RUN apt-get update && apt-get install -y build-essential
USER queil

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="/root/.cargo/bin:${PATH}"
