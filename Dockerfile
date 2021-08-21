FROM adoptopenjdk:11.0.11_9-jdk-hotspot-focal
LABEL maintainer="Dogukan Cagatay <dcagatay@gmail.com" \
      description="s6-overlay based Bamboo agent Docker image with dind support"

# Install s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.1/s6-overlay-amd64-installer /tmp/
RUN chmod +x /tmp/s6-overlay-amd64-installer && /tmp/s6-overlay-amd64-installer /

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    iputils-ping \
    iptables \
  && rm -rf /var/lib/apt/lists/*

ARG DOCKER_CHANNEL=stable
ARG DOCKER_VERSION=20.10.7

# Install docker
RUN export CHANNEL=${DOCKER_CHANNEL}; \
  export VERSION=${DOCKER_VERSION}; \
  curl -fsSL --retry 3 https://get.docker.com | sh

ENV DOCKER_EXTRA_OPTS "--log-level=error --experimental"
# For more options: https://docs.docker.com/engine/reference/commandline/dockerd/
# e.g. --insecure-registry myregistry:5000 --registry-mirrors http://myregistry:5000

# Install dind hack script
ARG DIND_COMMIT=42b1175eda071c0e9121e1d64345928384a93df1
RUN curl -fsSL --retry 3 "https://raw.githubusercontent.com/moby/moby/${DIND_COMMIT}/hack/dind" -o /usr/local/bin/dind \
  && chmod a+x /usr/local/bin/dind

# Install docker-compose
ARG DOCKER_COMPOSE_VERSION=1.29.2
RUN curl -fsSL --retry 3 "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

COPY services.d /etc/services.d


# Install Bamboo (modified from Atlassian's repo)
ENV BAMBOO_USER=bamboo

ENV BAMBOO_USER_HOME=/home/${BAMBOO_USER}
ENV BAMBOO_AGENT_HOME=${BAMBOO_USER_HOME}/bamboo-agent-home

ENV INIT_BAMBOO_CAPABILITIES=${BAMBOO_USER_HOME}/init-bamboo-capabilities.properties
ENV BAMBOO_CAPABILITIES=${BAMBOO_AGENT_HOME}/bin/bamboo-capabilities.properties

WORKDIR ${BAMBOO_USER_HOME}

ARG BAMBOO_VERSION=8.0.0
ARG DOWNLOAD_URL=https://packages.atlassian.com/maven-closedsource-local/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar
ENV AGENT_JAR=${BAMBOO_USER_HOME}/atlassian-bamboo-agent-installer.jar

RUN set -x && \
     curl -L --silent --output ${AGENT_JAR} ${DOWNLOAD_URL}

COPY bamboo-update-capability.sh bamboo-update-capability.sh
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jdk.JDK 11" ${JAVA_HOME}/bin/java
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.docker.executable" /usr/bin/docker
RUN ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.command.docker-compose" /usr/local/bin/docker-compose

COPY runAgent.sh runAgent.sh

VOLUME /var/lib/docker ${BAMBOO_AGENT_HOME}

ENTRYPOINT [ "/init" ]
