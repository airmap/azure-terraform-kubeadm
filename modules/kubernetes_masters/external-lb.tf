// External Master load balancer

resource "azurerm_lb" "external" {
  name                = "${var.name}-external"
  location            = var.region
  resource_group_name = var.resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "${var.name}-external"
    public_ip_address_id = azurerm_public_ip.loadbalancer.id
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

resource "azurerm_lb_backend_address_pool" "external" {
  name                = "${var.name}-external"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.external.id
}

resource "azurerm_network_interface_backend_address_pool_association" "external" {
  count                   = var.master_node_count
  network_interface_id    = element(azurerm_network_interface.primary.*.id, count.index)
  ip_configuration_name   = "ipconfig-${count.index}-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.external.id
}

resource "azurerm_lb_rule" "ext-rule1" {
  name                           = "${var.name}-HTTPS"
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.external.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 6443
  backend_address_pool_id        = azurerm_lb_backend_address_pool.external.id
  probe_id                       = azurerm_lb_probe.ext-https.id
  frontend_ip_configuration_name = "${var.name}-external"
  idle_timeout_in_minutes        = 5
  enable_floating_ip             = false //This has to be off or else incoming traffic will timeout.
}

resource "azurerm_lb_probe" "ext-https" {
  name                = "${var.name}-tcpHTTPSProbe"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.external.id
  port                = 6443
  interval_in_seconds = 5 //Interval inbetween probes
  number_of_probes    = 2 //Number of failed attempts
  protocol            = "Https"
  request_path        = "/healthz"
}

