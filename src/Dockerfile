FROM ubuntu:22.04

# user setup
ARG USER=queil
ARG GIT_USER=queil
ARG GIT_EMAIL=queil@users.noreply.github.com

ARG HOME=/home/$USER
RUN adduser $USER && groupadd docker && usermod -aG docker $USER

# software

RUN apt-get update && apt-get install -y curl git nano gnupg lsb-release

RUN mkdir -m 0755 -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y docker-ce-cli docker-buildx-plugin docker-compose-plugin


COPY --from=docker:cli /usr/local/bin/docker /usr/local/bin/docker
RUN curl -sSL https://starship.rs/install.sh -o ./install.sh && \
    chmod +x ./install.sh && ./install.sh --yes && rm ./install.sh

ARG VSCODE_GIT_HASH=441438abd1ac652551dbe4d408dfcec8a499b8bf

RUN curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o /tmp/vscode-server-linux-x64.tar.gz && \
    mkdir -p $HOME/.vscode-server/bin/$VSCODE_GIT_HASH && \
    mkdir -p $HOME/.vscode-server/data && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $HOME/.vscode-server/bin/$VSCODE_GIT_HASH --strip 1 && \
    chown $USER $HOME/.vscode-server/bin && \
    chown $USER $HOME/.vscode-server/data && \
    touch $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/0 && \
    rm /tmp/vscode-server-linux-x64.tar.gz

# config
WORKDIR $HOME

COPY starship.toml .config/
COPY .nanorc ./

RUN mkdir .nano && \
    git clone https://github.com/scopatz/nanorc.git .nano && \
    echo "include $HOME/.nano/*.nanorc" >> ~/.nanorc

RUN git config --global user.name "$GIT_USER" && git config --global user.email "$GIT_EMAIL"

# bashrc setup
RUN echo 'eval "$(starship init bash)"' >> .bashrc
RUN echo 'export CONTAINER_NAME=$(docker ps -f ID=$(hostname) --format "{{.Names}}")' >> .bashrc

USER $USER
