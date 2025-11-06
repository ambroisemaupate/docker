variable "REGISTRY" {
    default = "ambroisemaupate/restic-database"
}

group "default" {
    targets = ["restic"]
}

target "restic" {
    target = item.target
    name = "restic-${item.name}"
    platforms = ["linux/amd64"]
    context = "."
    dockerfile = "Dockerfile"
    tags = ["${REGISTRY}:${item.name}"]
    matrix = {
        item = [
            {
                name = "mysql"
                target = "mysql"
            },
            {
                name = "mariadb"
                target = "mariadb"
            },
            {
                name = "postgres"
                target = "postgres"
            }
        ]
    }
}
