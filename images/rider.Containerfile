FROM ghcr.io/queil/image:dotnet-10

USER root
RUN microdnf install --nodocs --setopt install_weak_deps=0 -y \
    openssh-server openssh-clients java-21-openjdk java-21-openjdk-devel icu mesa-libGL \
    && microdnf clean all

RUN mkdir -p /var/run/sshd && \
    ssh-keygen -A && \
    chmod 644 /etc/ssh/ssh_host_*_key && \
    chmod 644 /etc/ssh/ssh_host_*_key.pub && \
    chown queil:queil /etc/ssh/sshd_config && \
    echo "queil:rider" | chpasswd  && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "UsePAM no" >> /etc/ssh/sshd_config

USER queil

CMD ["/usr/sbin/sshd", "-D", "-p", "2222", "-E", "/dev/stderr"]
