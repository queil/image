FROM ghcr.io/queil/image:latest as python

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 poetry && microdnf clean all && rm -rf /var/cache/yum
USER queil

RUN code-server --install-extension ms-python.python
