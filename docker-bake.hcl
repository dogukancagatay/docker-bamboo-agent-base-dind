variable "IMAGE_NAME" {
    default = "dcagatay/bamboo-agent-base-dind"
}

variable "BAMBOO_AGENT_VERSION" {
    default = "8.0.0"
}

group "default" {
    targets = [ "8.0.0" ]
}

target "8.0.0" {
    context = "."
    platforms = [ "linux/amd64" ]
    dockerfile = "Dockerfile"
    args = {
        BAMBOO_AGENT_VERSION = "${BAMBOO_AGENT_VERSION}"
    }
    tags = [
        "docker.io/${IMAGE_NAME}:latest",
        "docker.io/${IMAGE_NAME}:${BAMBOO_AGENT_VERSION}"
    ]
    output = ["docker"]

}

// target "7.0.0" {
//     inherits = ["8.0.0"]
//     args = {
//         BAMBOO_AGENT_VERSION = "7.0.0"
//     }
//     tags = [
//         "docker.io/${IMAGE_NAME}:7.0.0"
//     ]
//     output = ["docker"]
// }
