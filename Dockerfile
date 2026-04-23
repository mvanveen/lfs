# Ubuntu-based build host for Linux From Scratch 12.4 (SysV).
# See: https://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LFS=/mnt/lfs

# hadolint ignore=DL3008
RUN apt-get update && apt-get install -y --no-install-recommends \
      build-essential openssh-server wget curl ca-certificates \
      bison gawk texinfo python3 python3-distutils-extra \
      m4 gperf gettext autopoint flex file xz-utils bzip2 \
      patch kpartx parted dosfstools sudo less vim-tiny \
      libncurses-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# Ensure /bin/sh is bash (required by LFS).
# hadolint ignore=DL4005
RUN ln -sfv bash /bin/sh

# SSH: root login via authorized_keys only.
RUN mkdir -p /root/.ssh /var/run/sshd && chmod 700 /root/.ssh && ssh-keygen -A
RUN sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config \
 && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config \
 && sed -i -e 's/^root:!:/root::/' /etc/shadow

# Pull public keys from GitHub for SSH auth.
RUN wget -q https://github.com/mvanveen.keys -O /root/.ssh/authorized_keys \
 && chmod 600 /root/.ssh/authorized_keys

COPY run.sh /run.sh
CMD ["/bin/bash", "/run.sh"]
