variable "region" {
}

variable "name" {
}

variable "resource_group" {
}

variable "control_plane_endpoint" {
}

variable "master_node_count" {
}

variable "master_vm_type" {
}

variable "cluster_subnet_id" {
}

variable "cluster_subnet_cidr" {
}

variable "pub_key" {
}

variable "platform_update_domain_count" {
}

variable "platform_fault_domain_count" {
}

variable "username" {
}

variable "kubernetes_version" {
}

variable "master_os_size" {
}

variable "master_etcd_size" {
}

variable "private_ssh_key" {
}

variable "kubernetes_blob_endpoint" {
}

variable "sas_string" {
}

variable "token" {
}

variable "admission_plugins" {
  type = list(string)
}

variable "whitelist" {
  type = list(string)
}

