// Azure Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.name
  address_space       = [var.vnet_cidr]
  location            = var.region
  resource_group_name = var.resource_group

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

