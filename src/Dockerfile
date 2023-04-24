FROM fedora:rawhide as base

ARG USER=queil
ARG GIT_USER=queil
ARG GIT_EMAIL=queil@users.noreply.github.com
ARG HOME=/home/$USER

# Software

RUN dnf update -y && \
    rpm --setcaps shadow-utils 2>/dev/null && \
    dnf install -y \
    bash-completion git nano bat dnsutils htop which \
    podman podman-compose slirp4netns fuse-overlayfs --exclude container-selinux && \

    dnf reinstall -y shadow-utils && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

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

ARG VSCODE_GIT_HASH=704ed70d4fd1c6bd6342c436f1ede30d1cff4710

RUN mkdir -p $HOME/.local/bin

RUN curl -sSL https://update.code.visualstudio.com/latest/server-linux-x64/stable -o /tmp/vscode-server-linux-x64.tar.gz && \
    mkdir -p $HOME/.vscode-server/bin/$VSCODE_GIT_HASH && \
    tar -zxvf /tmp/vscode-server-linux-x64.tar.gz -C $HOME/.vscode-server/bin/$VSCODE_GIT_HASH --strip 1 && \
    touch $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/0 && \
    rm /tmp/vscode-server-linux-x64.tar.gz

USER root
RUN ln -s $HOME/.vscode-server/bin/$VSCODE_GIT_HASH/bin/code-server /usr/bin/code-server
USER $USER

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

USER root

RUN dnf -y update && dnf install -y gcc && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

USER queil

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y

ENV PATH="${PATH}:${HOME}/.cargo/bin"

# VARIANT - PYTHON

FROM base as python

USER root

RUN ln -s /usr/bin/python3 /usr/bin/python && \
    dnf install -y poetry && dnf clean all && rm -rf /var/cache/yum

USER queil

RUN code-server --install-extension ms-python.python
