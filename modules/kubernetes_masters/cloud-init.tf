/*
Information on the cloud provider config:
https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/cloud-provider-config.md

Information on the Azure load balancer annotations:
https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/azure-loadbalancer.md

Information on the cluster autoscaler:
https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/azure/README.md
*/

// Master 0 cloud-init
data "template_file" "master_cloud_init" {
  template = file("${path.module}/files/master-cloud-init")

  vars = {
    region                   = lower(var.region)
    private_ssh_key          = base64encode(var.private_ssh_key) //Hack to get it past cloud-config.
    username                 = var.username
    data_dir                 = "/var/lib/etcd"
    kubernetes_version       = var.kubernetes_version
    kubernetes_blob_endpoint = var.kubernetes_blob_endpoint
    sas_string               = var.sas_string
  }
}

// Master 1 and 2 cloud-init
data "template_file" "other_master_cloud_init" {
  template = file("${path.module}/files/other-master-cloud-init")

  vars = {
    region                   = lower(var.region)
    username                 = var.username
    data_dir                 = "/var/lib/etcd"
    kubernetes_version       = var.kubernetes_version
    kubernetes_blob_endpoint = var.kubernetes_blob_endpoint
    sas_string               = var.sas_string
  }
}

// Master 0 only
data "template_file" "copy_certs" {
  template = file("${path.module}/files/copy_certs.sh")

  vars = {
    username          = var.username
    control_plane_ip1 = element(azurerm_network_interface.primary.*.private_ip_address, 1) //Problematic if more than 3 total masters
    control_plane_ip2 = element(azurerm_network_interface.primary.*.private_ip_address, 2) //Problematic if more than 3 total masters
  }
}

data "template_file" "master_bootstrap" {
  template = file("${path.module}/files/master_bootstrap.sh")

  vars = {
    username               = var.username
    control_plane_endpoint = var.control_plane_endpoint
    control_plane_ip1      = element(azurerm_network_interface.primary.*.private_ip_address, 1) //Problematic if more than 3 total masters
    control_plane_ip2      = element(azurerm_network_interface.primary.*.private_ip_address, 2) //Problematic if more than 3 total masters
  }
}

data "template_file" "kubeadm-config" {
  template = file("${path.module}/files/kubeadm-config.yaml")

  vars = {
    kubernetes_version             = var.kubernetes_version
    data_dir                       = "/var/lib/etcd"
    admission_plugins              = join(",", var.admission_plugins)
    control_plane_endpoint         = var.control_plane_endpoint
    external_loadbalancer_endpoint = azurerm_public_ip.loadbalancer.fqdn
    pod_subnet                     = "10.244.0.0/16" //Flannel
    token                          = var.token
    control_plane_ip0              = element(azurerm_network_interface.primary.*.private_ip_address, 0) //Problematic if more than 3 total masters
    control_plane_ip1              = element(azurerm_network_interface.primary.*.private_ip_address, 1) //Problematic if more than 3 total masters
    control_plane_ip2              = element(azurerm_network_interface.primary.*.private_ip_address, 2) //Problematic if more than 3 total masters
  }
}

