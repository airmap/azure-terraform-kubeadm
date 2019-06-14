resource "azurerm_postgresql_server" "main" {
  name                = var.name
  location            = var.region
  resource_group_name = var.resource_group

  sku {
    name     = var.sku_name[terraform.workspace]
    capacity = var.sku_capacity[terraform.workspace]
    tier     = var.sku_tier
    family   = var.sku_family
  }

  storage_profile {
    storage_mb            = var.db_storage[terraform.workspace]
    backup_retention_days = 21
    geo_redundant_backup  = "Enabled"
  }

  administrator_login          = var.username
  administrator_login_password = var.db_admin_password
  version                      = var.db_version[terraform.workspace]
  ssl_enforcement              = "Enabled"

  # We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing.
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_virtual_network_rule" "cluster" {
  name                = "${terraform.workspace}-cluster"
  resource_group_name = var.resource_group
  server_name         = azurerm_postgresql_server.main.name
  subnet_id           = var.cluster_subnet_id
}

resource "azurerm_postgresql_virtual_network_rule" "db" {
  name                = "${terraform.workspace}-db"
  resource_group_name = var.resource_group
  server_name         = azurerm_postgresql_server.main.name
  subnet_id           = var.db_subnet_id
}

resource "azurerm_postgresql_database" "main" {
  name                = "main"
  resource_group_name = var.resource_group
  server_name         = azurerm_postgresql_server.main.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "main-office" {
  count               = length(var.whitelist)
  name                = "office-${count.index}"
  resource_group_name = var.resource_group
  server_name         = azurerm_postgresql_server.main.name
  start_ip_address    = element(var.whitelist, count.index)
  end_ip_address      = element(var.whitelist, count.index)
}

