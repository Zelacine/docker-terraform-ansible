resource "docker_network" "app_network" {
  name = "${var.project_name}-network"
}