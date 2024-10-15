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

ARG ARGO_WF_VER=3.5.6

RUN curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_WF_VER}/argo-linux-amd64.gz && \
    gunzip argo-linux-amd64.gz && \
    chmod +x argo-linux-amd64 && mv ./argo-linux-amd64 /usr/bin/argo

ARG ARGO_CD_VER=2.12.4
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/${ARGO_CD_VER}/argocd-linux-amd64 && \
    chmod +x argocd-linux-amd64 && mv ./argocd-linux-amd64 /usr/bin/argocd

USER queil

ARG USER=queil
ARG HOME=/home/$USER

RUN echo 'alias k=kubectl' >> $HOME/.image.bashrc && \
    echo 'alias kb="kustomize build"' >> $HOME/.image.bashrc
