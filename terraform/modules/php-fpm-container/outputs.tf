output "container_id" {
  description = "PHP-FPM container ID"
  value       = docker_container.php_fpm.id
}

output "container_name" {
  description = "PHP-FPM container name"
  value       = docker_container.php_fpm.name
}