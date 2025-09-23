FROM ghcr.io/queil/image:latest

USER root

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    microdnf install -y dotnet-sdk-9.0 helm --nodocs --setopt install_weak_deps=0 && \
    microdnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm --nodocs --setopt install_weak_deps=0 && \
    microdnf install -y azure-cli --nodocs --setopt install_weak_deps=0 && \
    microdnf clean all && rm -rf /var/cache/yum && \
    az aks install-cli

ARG USER=queil
ARG HOME=/home/$USER

USER queil

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN code-server --install-extension Ionide.Ionide-fsharp && \
    code-server --install-extension ms-azuretools.vscode-bicep

RUN dotnet tool install --global fsy --version 0.20.0-alpha.2 && \
    dotnet tool install -g fsautocomplete && \
    dotnet tool install -g fantomas && fsy install-fsx-extensions

RUN mkdir -p ~/.config/micro/plug/lsp && \
    git clone -b fsharp https://github.com/queil/micro-plugin-lsp.git ~/.config/micro/plug/lsp


ARG KUSTOMIZE_VER=5.7.1
ARG KUBESEAL_VER=0.32.2
ARG ARGO_WF_VER=3.7.2
ARG ARGO_CD_VER=3.1.6
ARG STERN_VER=1.33.0

RUN eget kubernetes-sigs/kustomize  --tag="v${KUSTOMIZE_VER}" && \
    eget bitnami-labs/sealed-secrets --asset=kubeseal --asset=^.sig --file=kubeseal --tag="v${KUBESEAL_VER}" && \
    eget argoproj/argo-workflows --tag="${ARGO_WF_VER}" && \
    eget argoproj/argo-cd --tag="${ARGO_CD_VER}" && \
    eget stern/stern --tag="${STERN_VER}"

ENV USER=queil
ENV HOME=/home/$USER

RUN echo 'alias k=kubectl' >> $HOME/.image.bashrc && \
    echo 'alias kb="kustomize build"' >> $HOME/.image.bashrc
