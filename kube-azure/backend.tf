
//Change this backend configuration to fit you environment.
terraform {
  backend "azurerm" {
    storage_account_name = "example"
    resource_group_name  = "example-resource-group"
    container_name       = "example-container"
    key                  = "terraform.tfstate"
    arm_subscription_id  = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    arm_tenant_id        = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
}

