FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    systemd \
    curl \
    ca-certificates \
    fuse-overlayfs

RUN ln -sf /usr/lib/systemd/systemd /sbin/init

RUN curl -sfL https://get.k3s.io | \
    INSTALL_K3S_SKIP_ENABLE=true INSTALL_K3S_EXEC="--kubelet-arg=cgroup-driver=systemd --snapshotter=fuse-overlayfs --kubelet-arg=feature-gates=KubeletInUserNamespace=true --kube-proxy-arg=--feature-gates=KubeletInUserNamespace=true" sh -

RUN systemctl enable k3s
