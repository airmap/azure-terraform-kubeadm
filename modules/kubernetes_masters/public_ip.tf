// Public IP's for Masters

resource "azurerm_public_ip" "main" {
  count                   = var.master_node_count
  name                    = "${var.name}-${count.index}"
  location                = var.region
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 5

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

// Load balancer public IP
resource "azurerm_public_ip" "loadbalancer" {
  name                    = "${var.name}-loadbalancer"
  location                = var.region
  resource_group_name     = var.resource_group
  allocation_method       = "Static"
  sku                     = "Standard"
  idle_timeout_in_minutes = 5
  domain_name_label       = var.name

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

