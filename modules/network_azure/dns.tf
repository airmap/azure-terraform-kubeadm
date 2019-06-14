resource "azurerm_dns_zone" "main" {
  name                = "${var.name}.com"
  resource_group_name = var.resource_group
  zone_type           = "Private"

  #registration_virtual_network_ids = ["${azurerm_virtual_network.main.id}"]
  resolution_virtual_network_ids = [azurerm_virtual_network.main.id]

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

// Crappy hack to get around the kubeadm/Azure hairpinning issue
// Create record for ILB
resource "azurerm_dns_a_record" "internal_load_balancer" {
  name                = "ilb"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = var.resource_group
  ttl                 = 60
  records             = [cidrhost(azurerm_subnet.kubernetes.address_prefix, -2)]
}

