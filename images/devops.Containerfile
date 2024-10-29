FROM ghcr.io/queil/image:latest

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
