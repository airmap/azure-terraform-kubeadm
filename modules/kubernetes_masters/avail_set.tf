resource "azurerm_availability_set" "main" {
  name                         = var.name
  location                     = var.region
  resource_group_name          = var.resource_group
  managed                      = true
  platform_update_domain_count = var.platform_update_domain_count
  platform_fault_domain_count  = var.platform_fault_domain_count

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

