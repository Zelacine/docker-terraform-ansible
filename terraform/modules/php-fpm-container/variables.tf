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

variable "app_env" {
  description = "Application environment"
  type        = string
}

variable "image_name" {
  description = "PHP-FPM Docker image"
  type        = string
  default     = "php:8.2-fpm"
}