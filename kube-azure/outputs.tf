output "kubernetes_masters_ip" {
  value = module.kubernetes_masters.master_public_ip_address
}

output "masters_loadbalancer_fqdn" {
  value = module.kubernetes_masters.loadbalancer_public_fqdn
}

output "masters_internal_ip_address" {
  value = module.kubernetes_masters.loadbalancer_internal_ip_address
}

output "resource_group" {
  value = azurerm_resource_group.main.name
}

output "vmss_name" {
  value = module.kubernetes_workers.vmss_name
}

