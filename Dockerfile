FROM ubuntu:18.04

ENV LFS /

RUN apt-get update
RUN apt-get install -y build-essential openssh-server python3
#RUN apk add openssh
#RUN touch /run/openrc/softlevel
RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
RUN ssh-keygen -A
RUN sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config
RUN sed -i s/^#PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/ /etc/ssh/sshd_config
RUN sed -i -e 's/^root:!:/root::/' /etc/shadow

RUN wget https://github.com/mvanveen.keys -O /root/.ssh/authorized_keys
RUN mkdir /run/sshd

CMD ["/usr/sbin/sshd", "-D", "-e"]
