resource "docker_volume" "app_volume" {
  name = "${var.project_name}-volume"
}