// Network cards for each master with a private and public IP

resource "azurerm_network_interface" "primary" {
  count                     = var.master_node_count
  name                      = "${var.name}-${count.index}-primary"
  location                  = var.region
  resource_group_name       = var.resource_group
  internal_dns_name_label   = "${var.name}-${count.index}"
  network_security_group_id = azurerm_network_security_group.main.id
  enable_ip_forwarding      = "false"

  ip_configuration {
    primary                       = true
    name                          = "ipconfig-${count.index}-primary"
    subnet_id                     = var.cluster_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.main.*.id, count.index)
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

