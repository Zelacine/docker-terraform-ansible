# Variables
variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "php-app"
}

variable "host_port" {
  description = "Host port to expose Nginx"
  type        = number
  default     = 8080
}

variable "app_env" {
  description = "Application environment"
  type        = string
  default     = "dev"
}