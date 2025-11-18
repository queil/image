FROM ghcr.io/queil/image:latest

USER root
RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    openssh-server openssh-clients java-21-openjdk java-21-openjdk-devel icu \
    && microdnf clean all

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A

RUN echo "queil:rider" | chpasswd

USER queil

CMD ["/usr/sbin/sshd", "-D", "-p", "2222", "-E", "/dev/stderr"]
