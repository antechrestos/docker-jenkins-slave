Docker jenkins slave
====================

Description
-----------

This project provides two dockerfile to build a docker based jenkins slave with docker inside

Build arguments
---------------

- `JENKINS_PASSWORD` : jenkins password. Default is ` jenkins`
- `JENKINS_WORKDIR` : jenkins work directory. Default is `/var/jenkins`.

Run
---

To run it the container will need to be able to do it with docker daemon. This image can work sharing the docker daemon of the host. To do it, simply use the options `-v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker`. With this, the jenkins slave container will use docker host daemon and launch its image as if it were the host.

Do not forget to mount the working directory with a host directory so as not to lose data: `-v /tmp/jenkins_slave:/var/jenkins`.

The environment variable `SSHD_LISTENING_PORT` can also be provided to chose another port for ssh server (default is `22`).

Example sharing daemon docker with host and exposing the ssh port on host machine

```bash
$> docker run --rm  -v /tmp/jenkins_slave:/var/jenkins  -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -p 2222:22 -d docker-jenkins-slave:jdk8
```

Another example to use the network stack of the host machine (hence ssh server port will directly be exposed).

```bash
$> docker run --rm  -v /tmp/jenkins_slave:/var/jenkins  -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker -e SSHD_LISTENING_PORT=2222  --network=host -d  docker-jenkins-slave:jdk8
```

