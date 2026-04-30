FROM ghcr.io/queil/image:latest

ARG USER=queil
ARG HOME=/home/$USER

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN echo 'alias drf="dotnet nuget locals --clear http-cache && dotnet restore --use-lock-file --force-evaluate"' >> $HOME/.image.bashrc && \
    echo 'alias dlp="dotnet restore && dotnet list package --outdated"' >> $HOME/.image.bashrc

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 \
      # IronPDF deps
      chromium glibc-devel nss at-spi2-atk libXcomposite libXrandr mesa-libgbm alsa-lib pango cups-libs libXdamage libxshmfence \
      && microdnf clean all && rm -rf /var/cache/yum

RUN curl -sSL https://builds.dotnet.microsoft.com/dotnet/scripts/v1/dotnet-install.sh | bash -s -- --install-dir /usr/lib64/dotnet && ln -s /usr/lib64/dotnet/dotnet /usr/local/bin/dotnet

USER queil

RUN dotnet tool install -g fsautocomplete && \
    dotnet tool install -g fantomas && \
    dotnet tool install -g csharp-ls && \
    dotnet tool install -g ATech.Ring.DotNet.Cli && \
    dotnet tool install -g fsy --version 0.23.0 && fsy install-fsx-extensions
RUN mkdir -p ~/.config/micro/plug/lsp && \
    git clone -b fsharp https://github.com/queil/micro-plugin-lsp.git ~/.config/micro/plug/lsp
