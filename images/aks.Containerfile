FROM ghcr.io/queil/image:latest as aks

USER root

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    microdnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm --nodocs --setopt install_weak_deps=0 && \
    microdnf install -y azure-cli --nodocs --setopt install_weak_deps=0 && \
    microdnf clean all && rm -rf /var/cache/yum && \
    az aks install-cli

ARG KUSTOMIZE_VER=5.3.0

RUN curl -sSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VER}/kustomize_v${KUSTOMIZE_VER}_linux_amd64.tar.gz" -o /tmp/kustomize.tar.gz && \
    tar -zxvf /tmp/kustomize.tar.gz -C /tmp && \
    mv /tmp/kustomize /usr/bin && chmod +x /usr/bin/kustomize && \
    rm /tmp/kustomize.tar.gz


ARG KUBESEAL_VER=0.26.1

RUN curl -sSL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VER}/kubeseal-${KUBESEAL_VER}-linux-amd64.tar.gz" -o /tmp/kubeseal.tar.gz && \
    tar -zxvf /tmp/kubeseal.tar.gz -C /tmp && \
    mv /tmp/kubeseal /usr/bin && chmod +x /usr/bin/kubeseal && \
    rm /tmp/kubeseal.tar.gz

USER queil

RUN echo 'alias k=kubectl' >> .bashrc && \
    echo "alias kb='kustomize build'" >> .bashrc
