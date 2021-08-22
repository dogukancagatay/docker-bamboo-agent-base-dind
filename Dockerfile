FROM dcagatay/ubuntu-dind:20.04
LABEL maintainer="Dogukan Cagatay <dcagatay@gmail.com" \
      description="s6-overlay based Bamboo agent Docker image with dind support"

# Install Bamboo (modified from Atlassian's repo)
ENV BAMBOO_USER "bamboo"

ENV BAMBOO_USER_HOME "/home/${BAMBOO_USER}"
ENV BAMBOO_AGENT_HOME "${BAMBOO_USER_HOME}/bamboo-agent-home"

ENV INIT_BAMBOO_CAPABILITIES "${BAMBOO_USER_HOME}/init-bamboo-capabilities.properties"
ENV BAMBOO_CAPABILITIES "${BAMBOO_AGENT_HOME}/bin/bamboo-capabilities.properties"

ARG BAMBOO_AGENT_VERSION="8.0.0"
ARG BAMBOO_AGENT_DOWNLOAD_URL="https://packages.atlassian.com/maven-closedsource-local/com/atlassian/bamboo/atlassian-bamboo-agent-installer/${BAMBOO_AGENT_VERSION}/atlassian-bamboo-agent-installer-${BAMBOO_AGENT_VERSION}.jar"
ENV AGENT_JAR "${BAMBOO_USER_HOME}/atlassian-bamboo-agent-installer.jar"

RUN set -x && \
     mkdir -p ${BAMBOO_AGENT_HOME}/bin && \
     curl -fSL --retry 3 "${BAMBOO_AGENT_DOWNLOAD_URL}" -o "${AGENT_JAR}"

WORKDIR ${BAMBOO_USER_HOME}

COPY bamboo-update-capability.sh runAgent.sh ${BAMBOO_USER_HOME}/
COPY services.d/* /etc/services.d/

# Install Java 11
ARG JAVA_11_DOWNLOAD_URL="https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.11%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.11_9.tar.gz"
RUN curl -fSL --retry 3 "${JAVA_11_DOWNLOAD_URL}" -o /opt/java.tar.gz && \
  tar -xzf /opt/java.tar.gz -C /opt/ && \
  rm -rf /opt/java.tar.gz && \
  ln -s $(ls -1 /opt | grep jdk-) /opt/java-11-jdk

ENV JAVA_HOME "/opt/java-11-jdk"
ENV PATH "${JAVA_HOME}/bin:${PATH}"

RUN  ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.jdk.JDK 11" ${JAVA_HOME}/bin/java && \
     ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.docker.executable" /usr/bin/docker && \
     ${BAMBOO_USER_HOME}/bamboo-update-capability.sh "system.command.docker-compose" /usr/local/bin/docker-compose

VOLUME /var/lib/docker ${BAMBOO_AGENT_HOME}

ENTRYPOINT [ "/init" ]
