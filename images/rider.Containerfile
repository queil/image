FROM ghcr.io/queil/image:latest

RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    openssh-server openssh-clients java-21-openjdk java-21-openjdk-devel \
    && microdnf clean all

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A

RUN echo "queil:rider" | chpasswd

CMD ["/usr/sbin/sshd", "-D", "-p", "2222", "-E", "/dev/stderr"]
