FROM ghcr.io/queil/image:latest

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 python3-pip && microdnf clean all && rm -rf /var/cache/yum && \
    pip install --upgrade pip && pip install mkdocs
USER queil
