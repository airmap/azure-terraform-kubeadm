resource "azurerm_network_security_group" "main" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.region
}

