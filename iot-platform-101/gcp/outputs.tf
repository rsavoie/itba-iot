output "instance_ip" {
  description = "The public IP address of the Compute Engine instance."
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

output "grafana_url" {
  description = "URL to access Grafana using a nip.io DNS name."
  value       = "http://${google_compute_instance.default.network_interface[0].access_config[0].nat_ip}.nip.io:3000"
}
