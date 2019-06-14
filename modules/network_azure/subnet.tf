// This expects the vnet_cidr to be a /21, and creates a /22 for the cluster

resource "azurerm_subnet" "kubernetes" {
  name                 = "${var.name}-kubernetes"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = cidrsubnet(var.vnet_cidr, 1, 0)
  route_table_id       = azurerm_route_table.kubernetes.id
  depends_on           = [azurerm_virtual_network.main]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.KeyVault", "Microsoft.Storage"]
}

resource "azurerm_subnet_route_table_association" "kubernetes" {
  subnet_id      = azurerm_subnet.kubernetes.id
  route_table_id = azurerm_route_table.kubernetes.id
  depends_on     = [azurerm_subnet.kubernetes]
}

// This expects the vnet_cidr to be a /21, and creates a /24 for the db

resource "azurerm_subnet" "db" {
  name                 = "${var.name}-db"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = cidrsubnet(var.vnet_cidr, 3, 4)
  route_table_id       = azurerm_route_table.db.id
  depends_on           = [azurerm_virtual_network.main]
  service_endpoints    = ["Microsoft.Sql"]
}

resource "azurerm_subnet_route_table_association" "db" {
  subnet_id      = azurerm_subnet.db.id
  route_table_id = azurerm_route_table.db.id
  depends_on     = [azurerm_subnet.db]
}

