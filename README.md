# Bamboo Agent Docker Image with Docker-in-Docker Support

This Bamboo agent Docker image is based on Atlassian's [`docker-bamboo-agent-base`](https://bitbucket.org/atlassian-docker/docker-bamboo-agent-base/).


Please check their documentation for more information.

## Overview

This Docker image makes it easy to get an instance of Bamboo Agent up and running. This minimal image is suitable for customization and contains only AdoptOpenJDK 11, Bamboo Agent and Docker (as dind).

### Features

- Docker (as docker-in-docker)
- docker-compose
- s6-overlay


## Quick Start

For initialization, set `BAMBOO_SERVER_URL` environment variable, setup volume mapping for container's `/home/bamboo/bamboo-agent-home` directory, start the Docker container and follow Bamboo agent's instructions.

```bash
docker run --rm -it -v "$PWD/data:/home/bamboo/bamboo-agent-home" -e "BAMBOO_SERVER_URL=http://bamboo-server.example.com:8065" dcagatay/bamboo-agent-base-dind:latest
```

You can also use `docker-compose.yml` or any other container running environment in the same way.

### Environment Variables

- `BAMBOO_SERVER_URL`: URL of the Bamboo Server instance. *Required* E.g. `http://bamboo-server.example.com:8065`.
- `SECURITY_TOKEN`: If you have enabled security token on Bamboo Server. *Optional*.
- `DOCKER_EXTRA_OPTS`: Arguments to dockerd command. Details can be found on its [reference](https://docs.docker.com/engine/reference/commandline/dockerd/). *Optional* Default: --log-level=error --experimental


#### JVM Configuration

You can pass additional JVM arguments by using the `VM_OPTS` environment variable.

This way you can customize the Bamboo agent’s memory usage by overriding the wrapper’s default configuration. For example, to change the initial memory to 512MB and the maximum memory to 2048MB, add the following properties to your docker run command:

`-e VM_OPTS="-Dwrapper.java.initmemory=512 -Dwrapper.java.maxmemory=2048"`

For the list of all configuration properties, see [Wrapper configuration properties](https://wrapper.tanukisoftware.com/doc/english/properties.html).

### Volumes

In order to persist Agent data, you should map `/home/bamboo/bamboo-agent-home` to local directory or Docker Volume.


## Extending the image

If you need additional capabilities you can extend the image to suit your needs.

Note that the image uses s6-overlay, please do your modifications according to standard s6-overlay usage. Do not overwrite `ENTRYPOINT` or `CMD`.

Example of extending the agent base image by Maven and Git:

    FROM dcagatay/bamboo-agent-base-dind
    RUN apt-get update && \
        apt-get install maven -y && \
        apt-get install git -y
    RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.builder.mvn3.Maven 3.6" /usr/share/maven
    RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.git.executable" /usr/bin/git
