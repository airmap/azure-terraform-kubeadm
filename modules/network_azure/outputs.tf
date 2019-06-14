output "kubernetes_subnet_id" {
  value = azurerm_subnet.kubernetes.id
}

output "kubernetes_subnet_name" {
  value = azurerm_subnet.kubernetes.name
}

output "kubernetes_subnet_cidr" {
  value = azurerm_subnet.kubernetes.address_prefix
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "db_subnet_name" {
  value = azurerm_subnet.db.name
}

output "db_subnet_cidr" {
  value = azurerm_subnet.db.address_prefix
}

output "address_space" {
  value = azurerm_virtual_network.main.address_space
}

output "virtual_network_name" {
  value = azurerm_virtual_network.main.name
}

output "kubernetes_route_table_name" {
  value = azurerm_route_table.kubernetes.name
}

