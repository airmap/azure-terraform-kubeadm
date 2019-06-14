// This will typically fail upon creation because its waiting on the network to finish "updating"

resource "azurerm_storage_account" "main" {
  name                      = "${terraform.workspace}${replace(var.random_pet, "-", "")}"
  resource_group_name       = var.resource_group
  location                  = var.region
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS" // We dont care much about this as the files can be regenerated easily.
  enable_blob_encryption    = true
  enable_https_traffic_only = true

  network_rules {
    virtual_network_subnet_ids = [var.cluster_subnet_id]
    ip_rules                   = var.whitelist
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

