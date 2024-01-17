FROM ghcr.io/queil/image:dotnet-8

ENV AWS_EC2_METADATA_DISABLED=true

USER root

RUN microdnf install -y --nodocs --setopt install_weak_deps=0 awscli2 dotnet-sdk-8.0 nodejs nodejs-npm && microdnf clean all && rm -rf /var/cache/yum && \
    npm install -g aws-cdk

USER queil
