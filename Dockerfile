FROM ubuntu:18.04

ENV LFS /

RUN apt-get update
RUN apt-get install -y build-essential openssh-server python3 gawk bison texinfo
#RUN apk add openssh
#RUN touch /run/openrc/softlevel
RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
RUN ssh-keygen -A
RUN sed -i s/^#PasswordAuthentication\ yes/PasswordAuthentication\ no/ /etc/ssh/sshd_config
RUN sed -i s/^#PermitRootLogin\ prohibit-password/PermitRootLogin\ yes/ /etc/ssh/sshd_config
RUN sed -i -e 's/^root:!:/root::/' /etc/shadow

#RUN wget https://github.com/mvanveen.keys -O /root/.ssh/authorized_keys
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCTlJNPTiFhci20vrit7M+khv57nVrU80/Q4nVUk2SlrNvSk0RJ2avvcdCEqyClhgf8gIS7GRXMq/rUSqG5B0UUUKR14NxA9P0jzgK/dsBPEZsnLPSXTpqlHALEHEBhVG/m87ydEuraISbxYOD0ALauVxl6dHEaHZH6RI/LwS/rP02ZW2cc+TT5ZRrllstM1aOt3kViEJtYwfoCEL41ASfyMPPfj8+MaC7Z+bnAca/n/v3tMp2yJgQgahFZlNnw46MzBQtzhcTwxz8dDJUNklUviFx0sVU8Igc4ybjCHz6KxTXtNceKvZGz+eyNAzx8VLhGPz8EomI+PQXPJWNh3F2dSfVeaTrzYNkrAeDKFPLHNgYLmpjx3luf9+GUjUCi7nxGkjdGQzwoB8cQlJaBLwtY4ppaYrHHmAxWKVnMv+sxF118wN2eQMgwrUSqAJbwQ8xSAGqvwg/89DowqSfPcJpnNdBftkMo4eP1aqq/axtZGsv24QCtaioYpEkizfd0WFFP07MKSk3R6lrQ9bFDI1UYXvYLHyJ/K8iJZPAzz9RgiwEc8qEZUeLr34wSHUuKHNid6l1ljJTqaf/T/Zhy6qSsXWabXujgNlbwlSYujP5/38XJMACaheVsJMRiKxoUBkdHNW8i9dWHRPiNf+iHOSMMvHO/k8j6J20vthAukUIDKw== michael@mvanveen.net" > /root/.ssh/authorized_keys
#RUN mkdir /run/sshd
#CMD ["/usr/sbin/sshd", "-D", "-e"]

ADD run.sh .

CMD ["/bin/sh", "run.sh"]
