FROM ghcr.io/queil/image:dotnet-10

USER root
RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    java-21-openjdk java-21-openjdk-devel icu mesa-libGL \
    && microdnf clean all

USER queil
