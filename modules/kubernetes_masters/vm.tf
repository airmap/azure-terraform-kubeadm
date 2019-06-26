resource "azurerm_virtual_machine" "main" {
  name                             = "${var.name}-${count.index}"
  count                            = var.master_node_count
  location                         = var.region
  resource_group_name              = var.resource_group
  availability_set_id              = azurerm_availability_set.main.id
  network_interface_ids            = [element(azurerm_network_interface.primary.*.id, count.index)]
  primary_network_interface_id     = element(azurerm_network_interface.primary.*.id, count.index)
  vm_size                          = var.master_vm_type
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.name}-osdisk-${count.index}"
    create_option = "FromImage"
    caching       = "ReadWrite"
    os_type       = "Linux"
    disk_size_gb  = var.master_os_size
  }

  os_profile {
    computer_name  = "${var.name}-${count.index}"
    admin_username = var.username

    //This ensures that master 0 receives a different cloud-config script than master1 and master2.
    custom_data = count.index == 0 ? data.template_file.master_cloud_init.rendered : data.template_file.other_master_cloud_init.rendered
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = var.pub_key
      path     = "/home/${var.username}/.ssh/authorized_keys"
    }
  }

  storage_data_disk {
    name              = "${var.name}-etcddisk-${count.index}"
    caching           = "None"
    create_option     = "Empty"
    disk_size_gb      = var.master_etcd_size
    lun               = 0
    managed_disk_type = "Premium_LRS"
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }

  connection {
    host        = element(azurerm_public_ip.main.*.ip_address, count.index)
    type        = "ssh"
    user        = var.username
    private_key = var.private_ssh_key
  }

  // Rendered files
  provisioner "file" {
    content     = data.template_file.master_bootstrap.rendered
    destination = "/home/${var.username}/master_bootstrap.sh"
  }

  provisioner "file" {
    content     = data.template_file.copy_certs.rendered
    destination = "/home/${var.username}/copy_certs.sh"
  }

  provisioner "file" {
    content     = data.template_file.kubeadm-config.rendered
    destination = "/home/${var.username}/kubeadm-config.yaml"
  }
}

