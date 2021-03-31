FROM ubuntu:18.04

ENV LFS /

RUN apt-get update
RUN apt-get install -y build-essential openssh-server python3 gawk bison texinfo kpartx parallel

RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
RUN ssh-keygen -A
RUN sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config
RUN sed -i s/^#PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/ /etc/ssh/sshd_config
RUN sed -i -e 's/^root:!:/root::/' /etc/shadow

WORKDIR /root
ADD script/ .
ADD packages.txt .
ADD run.sh .
ADD pkg/prep/ .

CMD ["/bin/bash", "run.sh"]
