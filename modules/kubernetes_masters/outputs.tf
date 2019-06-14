output "master_public_ip_address" {
  value = azurerm_public_ip.main.*.ip_address
}

output "loadbalancer_public_ip_address" {
  value = azurerm_public_ip.loadbalancer.ip_address
}

output "loadbalancer_public_fqdn" {
  value = azurerm_public_ip.loadbalancer.fqdn
}

output "loadbalancer_internal_ip_address" {
  value = azurerm_lb.internal.private_ip_address
}

output "control_plane_endpoint" {
  value = element(azurerm_network_interface.primary.*.private_ip_address, 0)
}

output "security_group_name" {
  value = azurerm_network_security_group.main.name
}

