output "network_name" {
  description = "Docker network name"
  value       = module.network.network_name
}

output "volume_name" {
  description = "Docker volume name"
  value       = module.volume.volume_name
}

output "nginx_container_name" {
  description = "Nginx container name"
  value       = module.nginx.container_name
}

output "php_fpm_container_name" {
  description = "PHP-FPM container name"
  value       = module.php_fpm.container_name
}

output "healthz_url" {
  description = "Health check URL"
  value       = "http://localhost:${var.host_port}/healthz"
}

output "app_url" {
  description = "Application URL"
  value       = "http://localhost:${var.host_port}/"
}