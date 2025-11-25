output "volume_name" {
  description = "Docker volume name"
  value       = docker_volume.app_volume.name
}
