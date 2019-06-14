// Azure Route Table
resource "azurerm_route_table" "kubernetes" {
  name                          = "${var.name}-kubernetes"
  location                      = var.region
  resource_group_name           = var.resource_group
  disable_bgp_route_propagation = false
  depends_on                    = [azurerm_virtual_network.main]

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

resource "azurerm_route_table" "db" {
  name                          = "${var.name}-db"
  location                      = var.region
  resource_group_name           = var.resource_group
  disable_bgp_route_propagation = false
  depends_on                    = [azurerm_virtual_network.main]

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

