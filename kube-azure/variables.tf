variable "azure_subscription_id" {
}

variable "azure_client_id" {
}

variable "azure_client_secret" {
}

variable "azure_tenant_id" {
}

variable "github_organization" {
}

variable "github_token" {
}

variable "username" {
  description = "Username of virtual machines and databases"
}

variable "db_admin_password" {
  type = map(string)
}

variable "region" {
  type = map(string)
}

variable "whitelist" {
  type = list(string)
}

variable "vnet_cidr" {
  type = map(string)
}

variable "kubernetes_version" {
  description = "https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#support-timeframes"

  default = {
    default = "1.14.1"
  }
}

variable "master_node_count" {
  description = "Number of master VMs to create"
  type        = map(string)

  default = {
    default = "3"
  }
}

variable "worker_node_count" {
  description = "Number of worker VMs to initially create"
  type        = map(string)

  default = {
    default = "3"
  }
}

variable "master_vm_type" {
  description = "Virtual Machine Class"
  type        = map(string)

  default = {
    default = "Standard_F2s"
  }
}

variable "master_os_size" {
  description = "OS disk"
  type        = map(string)

  default = {
    default = 100
  }
}

variable "master_etcd_size" {
  description = "Etcd disk"
  type        = map(string)

  default = {
    default = 100
  }
}

variable "worker_vm_type" {
  description = "Virtual Machine Class"
  type        = map(string)

  default = {
    default = "Standard_E4s_v3"
  }
}

variable "worker_os_size" {
  description = "OS disk"
  type        = map(string)

  default = {
    default = 100
  }
}

//https://github.com/MicrosoftDocs/azure-docs/blob/master/includes/managed-disks-common-fault-domain-region-list.md

variable "platform_fault_domain_count" {
  type = map(string)

  default = {
    westus2    = 2
    centralus  = 3
    westeurope = 3
  }
}

variable "platform_update_domain_count" {
  type = map(string)

  default = {
    westus2    = 3
    centralus  = 5
    westeurope = 3
  }
}

variable "admission_plugins" {
  description = "List of plugins to enable on the cluster"
  type        = list(string)

  default = [
    "LimitRanger",
    "NamespaceLifecycle",
    "ServiceAccount",
    "DenyEscalatingExec",
    "PersistentVolumeLabel",
    "DefaultStorageClass",
    "DefaultTolerationSeconds",
    "NodeRestriction",
    "Priority",
    "ResourceQuota",
    "MutatingAdmissionWebhook",
    "ValidatingAdmissionWebhook",
    "PodSecurityPolicy",
  ]
}
