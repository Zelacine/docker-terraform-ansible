variable "project_name" {
  description = "Project name"
  type        = string
}

variable "network_name" {
  description = "Docker network name"
  type        = string
}

variable "volume_name" {
  description = "Docker volume name"
  type        = string
}

variable "host_port" {
  description = "Host port to expose"
  type        = number
}

variable "app_env" {
  description = "Application environment"
  type        = string
}

variable "php_fpm_name" {
  description = "PHP-FPM container name for networking"
  type        = string
}

variable "nginx_conf_path" {
  description = "Path to nginx.conf file"
  type        = string
}

variable "image_name" {
  description = "Nginx Docker image"
  type        = string
  default     = "nginx:alpine"
}