FROM ghcr.io/queil/image:latest

ARG USER=queil
ARG HOME=/home/$USER

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN echo 'alias drf="dotnet nuget locals --clear http-cache && dotnet restore --use-lock-file --force-evaluate"' >> $HOME/.image.bashrc && \
    echo 'alias dlp="dotnet restore && dotnet list package --outdated"' >> $HOME/.image.bashrc

RUN code-server --install-extension Ionide.Ionide-fsharp && \
    code-server --install-extension ms-dotnettools.csdevkit && \
    code-server --install-extension ms-mssql.data-workspace-vscode && \
    code-server --install-extension ms-mssql.mssql

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 \
      dotnet-sdk-8.0 \
      dotnet-sdk-9.0 \
      # IronPDF deps
      chromium glibc-devel nss at-spi2-atk libXcomposite libXrandr mesa-libgbm alsa-lib pango cups-libs libXdamage libxshmfence \
      && microdnf clean all && rm -rf /var/cache/yum

USER queil
RUN dotnet tool install -g fsautocomplete && \
    dotnet tool install -g fantomas && \
    dotnet tool install -g csharp-ls && \
    dotnet tool install -g ATech.Ring.DotNet.Cli && \
    dotnet tool install -g fsy && fsy install-fsx-extensions
RUN mkdir -p ~/.config/micro/plug/lsp && \
    git clone -b fsharp https://github.com/queil/micro-plugin-lsp.git ~/.config/micro/plug/lsp
