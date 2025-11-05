output "instance_ip" {
  description = "The public IP address of the Virtual Machine."
  value       = azurerm_public_ip.pip.ip_address
}

output "instance_fqdn" {
  description = "The FQDN of the Virtual Machine."
  value       = azurerm_public_ip.pip.fqdn
}

output "grafana_url" {
  description = "URL to access Grafana."
  value       = "http://${azurerm_public_ip.pip.fqdn}:3000"
}