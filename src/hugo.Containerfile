FROM ghcr.io/queil/image:latest

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 hugo nodejs && microdnf clean all && rm -rf /var/cache/yum
USER queil
