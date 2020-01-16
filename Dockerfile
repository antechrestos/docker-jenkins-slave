FROM openjdk:8u232-jdk-slim

ARG JENKINS_PASSWORD="jenkins"

ARG JENKINS_WORKDIR="/var/jenkins"

ARG SYSTEM_LOCALE="fr_FR"
ARG SYSTEM_ZONE="Europe/Paris"

ARG DEBIAN_REGISTRY=http://deb.debian.org
ARG DEBIAN_SECURITY_REGISTRY=http://security.debian.org


LABEL name="Docker Jenkins slave"                     \
      description="Docker Jenkins Slave"              \
      url="https://github.com/antechrestos/docker-jenkins-slave"                          \
      maintainer="antechrestos@gmail.com"

COPY entry-point.sh /usr/bin/entry-point.sh

RUN sed -i -e "s%^\(deb[^ ]*\) [^ ]*/debian/\? %\1 $DEBIAN_REGISTRY/debian/ %" \
           -e "s%^\(deb[^ ]*\) [^ ]*/debian-security/\? %\1 $DEBIAN_REGISTRY/debian-security/ %" \
           -e "s%^\(deb[^ ]*\) https\?://security.debian.org %\1 $DEBIAN_SECURITY_REGISTRY %" /etc/apt/sources.list

# Install locales and tools
RUN apt update                                                                                                                      && \
    DEBIAN_FRONTEND=noninteractive apt -qy install  locales locales-all tzdata gnupg2 apt-transport-https curl ca-certificates git  && \
    ln -fs /usr/share/zoneinfo/$SYSTEM_ZONE /etc/localtime                                                                          && \
    dpkg-reconfigure --frontend noninteractive tzdata                                                                               && \
    apt -qy autoremove                                                                                                              && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install openssh-server
RUN apt update                                                                                                   && \
    DEBIAN_FRONTEND=noninteractive apt -qy install  openssh-server                                               && \
    apt -qy autoremove                                                                                           && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*                                                                && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd

# Install docker and remove docker group as it will be created in entry-point.sh
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -                                  && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" >> /etc/apt/sources.list  && \
    apt update                                                                                               && \
    apt-cache policy docker-ce                                                                               && \
    apt -qy install docker-ce docker-ce-cli containerd.io --no-install-recommends apt-utils                  && \
    apt -qy autoremove                                                                                       && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*                                                            && \
    groupdel docker
 
# Create jenkins user
RUN adduser --quiet --home $JENKINS_WORKDIR jenkins && \
    echo "jenkins:$JENKINS_PASSWORD" | chpasswd     && \
    mkdir $JENKINS_WORKDIR/.ssh                     && \
    chown jenkins:jenkins $JENKINS_WORKDIR/.ssh     && \
    chmod 700 $JENKINS_WORKDIR/.ssh

#Create link for jenkins
RUN ln -fs /usr/local/openjdk-8/bin/java /usr/local/bin/java

VOLUME  [ "$JENKINS_WORKDIR" ]

USER root

ENV SSHD_LISTENING_PORT		22

ENV LANG              "$SYSTEM_LOCALE.UTF-8"
ENV LANGUAGE          ""
ENV LC_CTYPE          "$SYSTEM_LOCALE.UTF-8"
ENV LC_NUMERIC        "$SYSTEM_LOCALE.UTF-8"
ENV LC_TIME           "$SYSTEM_LOCALE.UTF-8"
ENV LC_COLLATE        "$SYSTEM_LOCALE.UTF-8"
ENV LC_MONETARY       "$SYSTEM_LOCALE.UTF-8"
ENV LC_MESSAGES       "$SYSTEM_LOCALE.UTF-8"
ENV LC_PAPER          "$SYSTEM_LOCALE.UTF-8"
ENV LC_NAME           "$SYSTEM_LOCALE.UTF-8"
ENV LC_ADDRESS        "$SYSTEM_LOCALE.UTF-8"
ENV LC_TELEPHONE      "$SYSTEM_LOCALE.UTF-8"
ENV LC_MEASUREMENT    "$SYSTEM_LOCALE.UTF-8"
ENV LC_IDENTIFICATION "$SYSTEM_LOCALE.UTF-8"

ENTRYPOINT [ "/usr/bin/entry-point.sh" ]

CMD [ "sh", "-c", "/usr/sbin/sshd -D -p ${SSHD_LISTENING_PORT}" ]

