FROM ghcr.io/queil/image:dotnet-10

USER root
RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    java-25-openjdk java-25-openjdk-devel icu mesa-libGL \
    && microdnf clean all

USER queil
