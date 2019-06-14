//https://kubernetes.io/docs/setup/independent/install-kubeadm/#before-you-begin

// The name of this VMSS is used by cloud.conf file to do autoscaling
resource "azurerm_virtual_machine_scale_set" "main" {
  name                = var.name
  location            = var.region
  resource_group_name = var.resource_group
  zones               = ["1", "2", "3"]
  upgrade_policy_mode = "Manual"
  overprovision       = false

  sku {
    name     = var.worker_vm_type
    tier     = "Standard"
    capacity = var.worker_node_count
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "StandardSSD_LRS"
    os_type           = "linux"
  }

  os_profile {
    computer_name_prefix = "${local.service}-${local.role}"
    admin_username       = var.username
    admin_password       = random_string.vm-login-password.result
    custom_data          = data.template_file.cloud_init.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = var.pub_key
    }
  }

  network_profile {
    name                      = "${var.name}-networkprofile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.main.id
    accelerated_networking    = false

    ip_configuration {
      name      = "${var.name}-ipprofile"
      primary   = true
      subnet_id = var.cluster_subnet_id
    }
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

