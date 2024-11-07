FROM ghcr.io/queil/image:latest

ARG USER=queil
ARG HOME=/home/$USER

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN code-server --install-extension Ionide.Ionide-fsharp && \
    code-server --install-extension ms-dotnettools.csdevkit

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 \
      dotnet-sdk-9.0 \
      && microdnf clean all && rm -rf /var/cache/yum


ARG WASMTIME_VER=26.0.1
RUN curl -sSL https://github.com/bytecodealliance/wasmtime/releases/download/v${WASMTIME_VER}/wasmtime-v${WASMTIME_VER}-x86_64-linux.tar.xz -o /tmp/wasmtime.tar.xz && \
    tar -xvf /tmp/wasmtime.tar.xz -C /tmp && \
    mv /tmp/wasmtime-v${WASMTIME_VER}-x86_64-linux/wasmtime /usr/bin && chmod +x /usr/bin/wasmtime && \
    rm /tmp/wasmtime.tar.xz
 
ARG WASM_TOOLS_VER=1.219.1
RUN curl -sSL https://github.com/bytecodealliance/wasm-tools/releases/download/v${WASM_TOOLS_VER}/wasm-tools-${WASM_TOOLS_VER}-x86_64-linux.tar.gz -o /tmp/wasm-tools.tar.gz && \
    tar -zxvf /tmp/wasm-tools.tar.gz -C /tmp && \
    mv /tmp/wasm-tools-${WASM_TOOLS_VER}-x86_64-linux/wasm-tools /usr/bin && chmod +x /usr/bin/wasm-tools && \
    rm /tmp/wasm-tools.tar.gz
 
USER queil

RUN dotnet workload install wasi-experimental

RUN mkdir -p ~/.config/micro/plug/lsp && \
    git clone -b fsharp https://github.com/queil/micro-plugin-lsp.git ~/.config/micro/plug/lsp
