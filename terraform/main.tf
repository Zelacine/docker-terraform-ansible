
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

module "network" {
  source       = "./modules/docker-network"
  project_name = var.project_name

  providers = {
    docker = docker
  }
}

module "volume" {
  source       = "./modules/docker-volume"
  project_name = var.project_name

  providers = {
    docker = docker
  }
}

# PHP-FPM Container Module
module "php_fpm" {
  source       = "./modules/php-fpm-container"
  project_name = var.project_name
  network_name = module.network.network_name
  volume_name  = module.volume.volume_name
  app_env      = var.app_env

  providers = {
    docker = docker
  }
}

# Nginx Container Module
module "nginx" {
  source = "./modules/nginx-container"

  project_name    = var.project_name
  network_name    = module.network.network_name
  volume_name     = module.volume.volume_name
  host_port       = var.host_port
  app_env         = var.app_env
  php_fpm_name    = module.php_fpm.container_name
  nginx_conf_path = abspath("${path.root}/nginx.conf")  

  providers = {
    docker = docker
  }

  depends_on = [module.php_fpm]
}