resource "template_dir" "main" {
  source_dir      = "${path.module}/files"
  destination_dir = "${path.module}/rendered"

  vars = {
    username               = var.username
    token                  = var.token
    control_plane_endpoint = var.control_plane_endpoint
    tenant_id              = var.azure_tenant_id
    client_id              = var.azure_client_id
    client_secret          = var.azure_client_secret
    subscription_id        = var.azure_subscription_id
    resource_group         = var.resource_group
    region                 = lower(var.region)
    subnet_name            = var.cluster_subnet_name
    security_group_name    = var.security_group_name
    virtual_network_name   = var.virtual_network_name
    route_table_name       = var.route_table_name
    load_balancer_sku      = "standard"    // Type of load balancer for kubernetes to generate
    vmss_name              = var.vmss_name // Backend for the loadbalancers
    vm_type                = "vmss"
  }
}

// Docker Setup
resource "azurerm_storage_blob" "docker_setup" {
  name                   = "docker_setup.sh"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/docker_setup.sh"

  lifecycle {
    ignore_changes = [source]
  }
}

// CNI Setup
resource "azurerm_storage_blob" "cni_setup" {
  name                   = "cni_setup.sh"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/cni_setup.sh"

  lifecycle {
    ignore_changes = [source]
  }
}

// Move Certs
resource "azurerm_storage_blob" "move_certs" {
  name                   = "move_certs.sh"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/move_certs.sh"

  lifecycle {
    ignore_changes = [source]
  }
}

// Join Configuration
resource "azurerm_storage_blob" "join_conf" {
  name                   = "join_conf.yaml"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/join_conf.yaml"

  lifecycle {
    ignore_changes = [source]
  }
}

// Worker Bootstrap
resource "azurerm_storage_blob" "worker_bootstrap" {
  name                   = "worker_bootstrap.sh"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/worker_bootstrap.sh"

  lifecycle {
    ignore_changes = [source]
  }
}

// Control Plane Bootstrap
resource "azurerm_storage_blob" "control_plane_bootstrap" {
  name                   = "control_plane_bootstrap.sh"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/control_plane_bootstrap.sh"

  lifecycle {
    ignore_changes = [source]
  }
}

//https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/cloud-provider-config.md

// This allows the cluster to provision PVC's, Load balancers, and other cloud specific resources
resource "azurerm_storage_blob" "cloud_provider" {
  name                   = "cloud.conf"
  resource_group_name    = var.resource_group
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.kubernetes.name
  type                   = "block"
  source                 = "${template_dir.main.destination_dir}/cloud.conf"

  lifecycle {
    ignore_changes = [source]
  }
}

