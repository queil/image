FROM ghcr.io/queil/image:latest as devops

ARG AWS_VAULT_VER=7.2.0

ENV AWS_VAULT_BACKEND=file
ENV AWS_EC2_METADATA_DISABLED=true

USER root

RUN curl -sSL https://github.com/99designs/aws-vault/releases/download/v${AWS_VAULT_VER}/aws-vault-linux-amd64 -o /usr/bin/aws-vault && \
    chmod +x /usr/bin/aws-vault

RUN microdnf install -y --nodocs --setopt install_weak_deps=0 awscli2 dotnet-sdk-8.0 nodejs nodejs-npm && microdnf clean all && rm -rf /var/cache/yum && \
    npm install -g aws-cdk

USER queil
