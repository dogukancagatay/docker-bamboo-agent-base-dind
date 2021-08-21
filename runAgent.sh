#!/bin/bash
set -euo pipefail

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

if [ -z ${BAMBOO_SERVER_URL+x} ]; then
    echo "Please set BAMBOO_SERVER_URL environment variable. E.g. http://bamboo-server.example.com:8085"
    exit 1
fi

if [ ! -f ${BAMBOO_CAPABILITIES} ]; then
    cp ${INIT_BAMBOO_CAPABILITIES} ${BAMBOO_CAPABILITIES}
fi

if [ -z ${SECURITY_TOKEN+x} ]; then
    exec java ${VM_OPTS:-} -jar "${AGENT_JAR}" "${BAMBOO_SERVER_URL}/agentServer/"
else
    exec java ${VM_OPTS:-} -jar "${AGENT_JAR}" "${BAMBOO_SERVER_URL}/agentServer/" -t "${SECURITY_TOKEN}"
fi
