FROM openjdk:8-jdk-alpine

ARG JENKINS_PASSWORD="jenkins"

ARG JENKINS_WORKDIR="/var/jenkins"

LABEL name="Docker Jenkins slave"                     \
      description="Docker Jenkins Slave"              \
      url="https://github.com/antechrestos/docker-jenkins-slave"                          \
      maintainer="antechrestos@gmail.com"

COPY entry-point.sh /usr/bin/entry-point.sh

# Install docker, git and sshd and remove docker group as it will be created in entry-point.sh
RUN apk add --update --no-cache docker git git-lfs openssh && \
	ssh-keygen -t rsa -N "" -f /etc/ssh/ssh_host_rsa_key && \
	ssh-keygen -t ecdsa -N ""  -f /etc/ssh/ssh_host_ecdsa_key && \
	ssh-keygen -t ed25519  -N ""  -f /etc/ssh/ssh_host_ed25519_key && \
	delgroup docker && \
	rm -rf /var/cache/apk/* 
	

# Create jenkins user
RUN adduser -h $JENKINS_WORKDIR -s /bin/sh -D jenkins && \
    echo "jenkins:$JENKINS_PASSWORD" | chpasswd

VOLUME  [ "$JENKINS_WORKDIR" ]

USER root

ENV SSHD_LISTENING_PORT		22

ENTRYPOINT [ "/usr/bin/entry-point.sh" ]

CMD [ "sh", "-c", "/usr/sbin/sshd -D -p ${SSHD_LISTENING_PORT}" ]

