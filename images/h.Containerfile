FROM registry.fedoraproject.org/fedora-minimal:39 as init

RUN microdnf install -y --nodocs --setopt install_weak_deps=0 git

ENV USER=queil
ARG INIT_REPO=https://github.com/queil/image
ARG INIT_BRANCH=init-home
ARG INIT_DIR=/init

WORKDIR $INIT_DIR

RUN git clone --no-checkout $INIT_REPO . && \
    git sparse-checkout init --cone && \
    git sparse-checkout set ".$INIT_DIR" && \
    git checkout $INIT_BRANCH && \
    ".$INIT_DIR/init.sh"

FROM init
