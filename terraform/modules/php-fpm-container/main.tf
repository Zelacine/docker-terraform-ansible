resource "docker_image" "php_fpm" {
  name = var.image_name
}

resource "docker_container" "php_fpm" {
  name  = "${var.project_name}-php-fpm"
  image = docker_image.php_fpm.image_id

  networks_advanced {
    name = var.network_name
  }

  volumes {
    volume_name    = var.volume_name
    container_path = "/var/www/html"
  }

  env = [
    "APP_ENV=${var.app_env}"
  ]

  restart = "unless-stopped"
}