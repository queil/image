FROM docker.io/fedora:43

RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    procps-ng \
    openssh-server \
    openssh-clients \
    java-21-openjdk \
    java-21-openjdk-devel \
    && microdnf clean all

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A

RUN groupadd -g 1000 rider && \
    useradd -m -u 1000 -g 1000 -s /bin/bash rider && \
    echo "rider:password" | chpasswd

CMD ["/usr/sbin/sshd", "-D", "-p", "2222", "-E", "/dev/stderr"]
