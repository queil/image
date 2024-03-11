FROM ghcr.io/queil/image:latest

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 hugo mkdocs nodejs nodejs-npm && microdnf clean all && rm -rf /var/cache/yum
USER queil
