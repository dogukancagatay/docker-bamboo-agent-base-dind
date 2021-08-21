variable "IMAGE_NAME" {
    default = "dcagatay/bamboo-agent-base-dind"
}

variable "DOCKER_VERSION" {
    default = "20.10.7"
}

variable "DOCKER_COMPOSE_VERSION" {
    default = "1.29.2"
}

variable "BAMBOO_VERSION" {
    default = "8.0.0"
}

group "default" {
    targets = [ "latest", "8.0.0" ]
}

target "latest" {
    context = "."
    platforms = [ "linux/amd64" ]
//     platforms = [ "linux/amd64", "linux/arm/v7", "linux/arm64/v8" ]
    dockerfile = "Dockerfile"
    args = {
	BAMBOO_VERSION = "${BAMBOO_VERSION}"
	DOCKER_VERSION = "${DOCKER_VERSION}"
	DOCKER_COMPOSE_VERSION = "${DOCKER_COMPOSE_VERSION}"
    }
    tags = [
        "docker.io/${IMAGE_NAME}:latest"
    ]
}

target "8.0.0" {
    inherits = ["latest"]
    args = {
	BAMBOO_VERSION = "${BAMBOO_VERSION}"
	DOCKER_VERSION = "${DOCKER_VERSION}"
	DOCKER_COMPOSE_VERSION = "${DOCKER_COMPOSE_VERSION}"
    }
    tags = [
        "docker.io/${IMAGE_NAME}:${BAMBOO_VERSION}"
    ]
}
