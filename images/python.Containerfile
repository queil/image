FROM ghcr.io/queil/image:latest

USER root
ARG ACCEPT_EULA=Y 
RUN curl https://packages.microsoft.com/config/rhel/8/prod.repo > /etc/yum.repos.d/mssql-release.repo && \
    microdnf install -y --nodocs --setopt install_weak_deps=0 poetry unixODBC unixODBC-devel msodbcsql18 && microdnf clean all && rm -rf /var/cache/yum
USER queil

RUN code-server --install-extension ms-python.python
