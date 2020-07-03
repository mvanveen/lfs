FROM alpine

ENV LFS /

RUN apk add build-base
RUN apk add openrc
RUN apk add openssh
RUN apk add bash # needed for LFS
RUN rc-update add sshd
RUN rc-status
RUN touch /run/openrc/softlevel
RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
RUN ssh-keygen -A
RUN sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config
RUN sed -i s/^#PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/ /etc/ssh/sshd_config
RUN sed -i -e 's/^root:!:/root::/' /etc/shadow

RUN wget https://github.com/mvanveen.keys -O /root/.ssh/authorized_keys

CMD ["/usr/sbin/sshd", "-D", "-e"]
