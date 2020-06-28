FROM ubuntu:focal

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    bc \
    build-essential \
    ca-certificates \
    cpio \
    dnsmasq \
    file \
    iproute2 \
    iptables \
    gcc-aarch64-linux-gnu \
    python3 \
    qemu-system \
    qemu-utils \
    rsync \
    ssh-client \
    unzip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# don't create buildroot as root
RUN useradd -ms /bin/bash buildroot
USER buildroot
ENTRYPOINT ["/bin/bash"]
