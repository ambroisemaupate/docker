variable "REGISTRY" {
    default = "ambroisemaupate/s3-backup"
}

group "default" {
    targets = ["s3-backup"]
}

target "s3-backup" {
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:latest"]
}
