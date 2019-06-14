provider "azurerm" {
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
  version         = "~> 1.30.1"
  alias           = "azure"
}

// :)
resource "random_pet" "main" {
  length = 2
}

// Generate a random string for the kubeadm join token in the format [a-z0-9]{6}.[a-z0-9]{16}
resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

// Azure Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${terraform.workspace}-${var.region[terraform.workspace]}-${random_pet.main.id}"
  location = var.region[terraform.workspace]

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

module "github" {
  source              = "../modules/github"
  github_token        = var.github_token
  github_organization = var.github_organization
  repo_name           = "${terraform.workspace}-${var.region[terraform.workspace]}-${random_pet.main.id}"
}

module "network" {
  source         = "../modules/network_azure"
  region         = var.region[terraform.workspace]
  resource_group = azurerm_resource_group.main.name
  name           = "${terraform.workspace}-network-${lower(var.region[terraform.workspace])}-${random_pet.main.id}"
  vnet_cidr      = var.vnet_cidr[terraform.workspace]
}

module "storage" {
  source                 = "../modules/storage_azure"
  region                 = var.region[terraform.workspace]
  resource_group         = azurerm_resource_group.main.name
  name                   = "${terraform.workspace}-storage-${lower(var.region[terraform.workspace])}-${random_pet.main.id}"
  whitelist              = var.whitelist
  random_pet             = random_pet.main.id
  cluster_subnet_id      = module.network.kubernetes_subnet_id
  username               = var.username
  token                  = "${random_string.token_id.result}.${random_string.token_secret.result}"
  control_plane_endpoint = "ilb.${terraform.workspace}-network-${lower(var.region[terraform.workspace])}-${random_pet.main.id}.com"
  azure_subscription_id  = var.azure_subscription_id
  azure_client_id        = var.azure_client_id
  azure_client_secret    = var.azure_client_secret
  azure_tenant_id        = var.azure_tenant_id
  cluster_subnet_name    = module.network.kubernetes_subnet_name
  virtual_network_name   = module.network.virtual_network_name
  route_table_name       = module.network.kubernetes_route_table_name
  vmss_name              = module.kubernetes_workers.vmss_name
  security_group_name    = module.kubernetes_workers.security_group_name
}

module "kubernetes_masters" {
  source                       = "../modules/kubernetes_masters"
  region                       = var.region[terraform.workspace]
  resource_group               = azurerm_resource_group.main.name
  name                         = "${terraform.workspace}-kubernetesmasters-${lower(var.region[terraform.workspace])}-${random_pet.main.id}"
  cluster_subnet_id            = module.network.kubernetes_subnet_id
  cluster_subnet_cidr          = module.network.kubernetes_subnet_cidr
  control_plane_endpoint       = "ilb.${terraform.workspace}-network-${lower(var.region[terraform.workspace])}-${random_pet.main.id}.com"
  master_node_count            = var.master_node_count[terraform.workspace]
  master_vm_type               = var.master_vm_type[terraform.workspace]
  platform_update_domain_count = var.platform_update_domain_count[var.region[terraform.workspace]]
  platform_fault_domain_count  = var.platform_fault_domain_count[var.region[terraform.workspace]]
  whitelist                    = var.whitelist
  username                     = var.username
  private_ssh_key              = tls_private_key.main.private_key_pem
  pub_key                      = tls_private_key.main.public_key_openssh
  kubernetes_version           = var.kubernetes_version[terraform.workspace]
  master_os_size               = var.master_os_size[terraform.workspace]
  master_etcd_size             = var.master_etcd_size[terraform.workspace]
  admission_plugins            = var.admission_plugins
  kubernetes_blob_endpoint     = module.storage.kubernetes_blob_endpoint
  sas_string                   = module.storage.sas_string
  token                        = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

module "kubernetes_workers" {
  name                     = "${terraform.workspace}-kubernetesworkers-${lower(var.region[terraform.workspace])}-${random_pet.main.id}"
  source                   = "../modules/kubernetes_workers_vmss"
  region                   = var.region[terraform.workspace]
  resource_group           = azurerm_resource_group.main.name
  cluster_subnet_id        = module.network.kubernetes_subnet_id
  worker_node_count        = var.worker_node_count[terraform.workspace]
  worker_vm_type           = var.worker_vm_type[terraform.workspace]
  username                 = var.username
  pub_key                  = tls_private_key.main.public_key_openssh
  kubernetes_version       = var.kubernetes_version[terraform.workspace]
  kubernetes_blob_endpoint = module.storage.kubernetes_blob_endpoint
  sas_string               = module.storage.sas_string
}

module "single_database" {
  source            = "../modules/single_database_azure"
  resource_group    = azurerm_resource_group.main.name
  username          = var.username
  db_admin_password = var.db_admin_password[terraform.workspace]
  region            = var.region[terraform.workspace]
  cluster_subnet_id = module.network.kubernetes_subnet_id
  db_subnet_id      = module.network.db_subnet_id
  name              = "${terraform.workspace}-database-${lower(var.region[terraform.workspace])}-${random_pet.main.id}"
  whitelist         = var.whitelist
}
