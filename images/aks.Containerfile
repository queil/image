FROM ghcr.io/queil/image:latest

USER root

# bicep language server requries dotnet 8.0
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    microdnf install -y --nodocs --setopt install_weak_deps=0 --enablerepo=updates-testing dotnet-sdk-10.0 && \
    microdnf install -y dotnet-sdk-8.0 helm --nodocs --setopt install_weak_deps=0 && \
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

ARG BICEP_LSP_VER=0.38.5
ARG BICEP_WRAPPER_PATH=$HOME/.local/bin/bicep-lsp

RUN code-server --accept-server-license-terms --install-extension Ionide.Ionide-fsharp && \
    code-server --accept-server-license-terms --install-extension "ms-azuretools.vscode-bicep@${BICEP_LSP_VER}" && \
    echo '#!/bin/bash' > $BICEP_WRAPPER_PATH && \
    echo "exec dotnet ${HOME}/.vscode-server/extensions/ms-azuretools.vscode-bicep-${BICEP_LSP_VER}/bicepLanguageServer/Bicep.LangServer.dll \"$@\"" >> $BICEP_WRAPPER_PATH && \
    chmod +x $BICEP_WRAPPER_PATH

RUN dotnet tool install --global fsy --version 0.22.0 && \
    dotnet tool install -g fsautocomplete && \
    dotnet tool install -g fantomas && fsy install-fsx-extensions

RUN mkdir -p ~/.config/micro/plug/lsp && \
    git clone -b fsharp https://github.com/queil/micro-plugin-lsp.git ~/.config/micro/plug/lsp

ARG KUSTOMIZE_VER=5.8.1
ARG KUBESEAL_VER=0.35.0
ARG ARGO_WF_VER=4.0.1
ARG ARGO_CD_VER=3.3.2
ARG STERN_VER=1.33.1

RUN eget kubernetes-sigs/kustomize  --tag="v${KUSTOMIZE_VER}" && \
    eget bitnami-labs/sealed-secrets --asset=kubeseal --asset=^.sig --file=kubeseal --tag="v${KUBESEAL_VER}" && \
    eget argoproj/argo-workflows --tag="${ARGO_WF_VER}" && \
    eget argoproj/argo-cd --tag="${ARGO_CD_VER}" && \
    eget stern/stern --tag="${STERN_VER}"

RUN echo 'alias k=kubectl' >> $HOME/.image.bashrc && \
    echo 'alias kb="kustomize build"' >> $HOME/.image.bashrc
