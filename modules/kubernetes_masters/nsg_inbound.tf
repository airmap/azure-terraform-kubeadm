//https://kubernetes.io/docs/setup/independent/install-kubeadm/#check-required-ports

//Whitelisted IP Kube TLS
resource "azurerm_network_security_rule" "allow_kube_tls" {
  name                        = "allow_kube_tls"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["443", "6443"]
  source_address_prefixes     = var.whitelist
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.main.name
}

// Master IP's Kube TLS
resource "azurerm_network_security_rule" "allow_master_kube_tls" {
  name                        = "allow_master_kube_tls"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_ranges     = ["443", "6443"]
  source_address_prefixes     = azurerm_public_ip.main.*.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.main.name
}

// SSH
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "allow_ssh"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = 22
  source_address_prefixes     = var.whitelist
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.main.name
}

