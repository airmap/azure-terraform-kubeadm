resource "azurerm_storage_container" "kubernetes" {
  name                  = "kubernetes"
  resource_group_name   = var.resource_group
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

