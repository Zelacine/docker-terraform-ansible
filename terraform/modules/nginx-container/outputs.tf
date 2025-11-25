output "container_id" {
  description = "Nginx container ID"
  value       = docker_container.nginx.id
}

output "container_name" {
  description = "Nginx container name"
  value       = docker_container.nginx.name
}

output "external_port" {
  description = "External port"
  value       = var.host_port
}