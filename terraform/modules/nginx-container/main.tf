# ============================================
# MODULE: nginx-container/main.tf
# ============================================
resource "docker_image" "nginx" {
  name = var.image_name
}

resource "docker_container" "nginx" {
  name  = "${var.project_name}-nginx"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = var.network_name
  }

  volumes {
    volume_name    = var.volume_name
    container_path = "/var/www/html"
    read_only      = true
  }

  volumes {
    host_path      = var.nginx_conf_path
    container_path = "/etc/nginx/conf.d/default.conf"
    read_only      = true
  }

  ports {
    internal = 80
    external = var.host_port
  }

  env = [
    "APP_ENV=${var.app_env}"
  ]

  restart = "unless-stopped"
}