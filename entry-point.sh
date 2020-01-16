#!/bin/sh


#Generate proxies configuration
echo "export http_proxy=$http_proxy
export https_proxy=$https_proxy" > /etc/profile.d/proxies.sh


# Handle rights on docker socker. Add a docker group with valid id on docker socket and add jenkins to this group
DOCKER_SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
EXISTING_GROUP=$(grep ":$DOCKER_SOCK_GID:" /etc/group | cut -d":" -f1)
if [ -n "$EXISTING_GROUP" ]
then
  delgroup $EXISTING_GROUP
fi
groupadd -g $DOCKER_SOCK_GID docker
adduser jenkins docker

exec "$@"
