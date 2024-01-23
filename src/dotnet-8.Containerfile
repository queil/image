FROM ghcr.io/queil/image:latest

ENV DOTNET_CLI_TELEMETRY_OPTOUT=true
ENV DOTNET_NOLOGO=true
ENV PATH="${PATH}:${HOME}/.dotnet/tools"

RUN code-server --install-extension Ionide.Ionide-fsharp

USER root
RUN microdnf install -y --nodocs --setopt install_weak_deps=0 dotnet-sdk-8.0 && microdnf clean all && rm -rf /var/cache/yum
USER queil
RUN dotnet tool install -g fsautocomplete && dotnet tool install -g fantomas
