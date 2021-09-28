FROM ubuntu:18.04 as lfs-base

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        build-essential \
	openssh-server \
	python3 \
	gawk \
	bison \
	texinfo \
	kpartx \
	parallel \
	zlib1g-dev \
	dejagnu \
	expect

#RUN mkdir -p /root/.ssh && chmod 0700 /root/.ssh
#RUN ssh-keygen -A && \
#    sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config && \
#    sed -i s/^#PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/ /etc/ssh/sshd_config && \
#    sed -i -e 's/^root:!:/root::/' /etc/shadow

WORKDIR /root
COPY --chmod=0755 ./script/ /root/script

WORKDIR /root/script
RUN /root/script/stage0.sh

RUN mkdir -p /mnt/lfs
RUN mkdir -p /mnt/lfs/sources/
RUN /root/script/stage1.sh

WORKDIR /root

COPY --chmod=0755 ./packages.txt /root/packages.txt
RUN bash -c "cat /root/packages.txt | parallel 'wget --continue --directory-prefix=/mnt/lfs/sources {}' | tee /var/log/output.txt"
COPY --chmod=0755 ./run.sh /root/run.sh

COPY --chmod=0777 ./pkg/prep/ /root
RUN chmod -R 777 /root && chown -R lfs /root

COPY --chmod=0777 ./pkg/build/ /mnt/lfs/sources
RUN chmod -R 777 /mnt/lfs/sources && chown -R lfs /mnt/lfs/sources

WORKDIR /root

ENV NUM_PROCS 24

#CMD ["/bin/bash", "run.sh"]
CMD ["tail", "-f", "/dev/null"]
