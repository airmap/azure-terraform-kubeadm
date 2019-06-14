// Build out a basic NSG.  We do not need any special rules other than the defaults
resource "azurerm_network_security_group" "main" {
  name                = var.name
  resource_group_name = var.resource_group
  location            = var.region
}

