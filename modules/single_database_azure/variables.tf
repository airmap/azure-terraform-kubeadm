// Required Variables

variable "username" {
}

variable "db_admin_password" {
}

variable "region" {
}

variable "cluster_subnet_id" {
}

variable "db_subnet_id" {
}

variable "name" {
}

variable "resource_group" {
}

// Optional Variables with default values

variable "db_version" {
  description = "Postgres version"
  type        = map(string)

  default = {
    default = "9.6"
  }
}

variable "sku_name" {
  description = "Azure SKU Name"
  type        = map(string)

  default = {
    default = "MO_Gen5_4"
  }
}

variable "sku_capacity" {
  description = "Number of vCPU units"
  type        = map(string)

  default = {
    default = "4"
  }
}

variable "sku_tier" {
  description = "Tier of usage"
  default     = "MemoryOptimized"
}

variable "sku_family" {
  description = "Family of CPUs"
  default     = "Gen5" # MO_Gen5_2 can only be Gen5
}

variable "db_storage" {
  description = "Storage in MB for database"
  type        = map(string)

  default = {
    default = "204800" # 200GB
  }
}

variable "whitelist" {
  type = list(string)
}

