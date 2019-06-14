//Internal Master load balancer

resource "azurerm_lb" "internal" {
  name                = "${var.name}-internal"
  location            = var.region
  resource_group_name = var.resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "${var.name}-internal"
    private_ip_address            = cidrhost(var.cluster_subnet_cidr, -2) // Internal IP is at the end of the subnet
    private_ip_address_allocation = "Static"
    subnet_id                     = var.cluster_subnet_id
    //zones                         = ["1", "2", "3"]
  }

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
    Purpose     = local.purpose
  }
}

resource "azurerm_lb_backend_address_pool" "internal" {
  name                = "${var.name}-internal"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.internal.id
}

resource "azurerm_network_interface_backend_address_pool_association" "internal" {
  count                   = var.master_node_count
  network_interface_id    = element(azurerm_network_interface.primary.*.id, count.index)
  ip_configuration_name   = "ipconfig-${count.index}-primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal.id
}

resource "azurerm_lb_rule" "int-rule1" {
  name                           = "${var.name}-HTTPS"
  resource_group_name            = var.resource_group
  loadbalancer_id                = azurerm_lb.internal.id
  protocol                       = "Tcp"
  frontend_port                  = 6443
  backend_port                   = 6443
  backend_address_pool_id        = azurerm_lb_backend_address_pool.internal.id
  probe_id                       = azurerm_lb_probe.int-https.id
  frontend_ip_configuration_name = "${var.name}-internal"
  idle_timeout_in_minutes        = 5
  enable_floating_ip             = false //This has to be off or else incoming traffic will timeout.
}

resource "azurerm_lb_probe" "int-https" {
  name                = "${var.name}-tcpHTTPSProbe"
  resource_group_name = var.resource_group
  loadbalancer_id     = azurerm_lb.internal.id
  port                = 6443
  interval_in_seconds = 5 //Interval inbetween probes
  number_of_probes    = 2 //Number of failed attempts
  protocol            = "Https"
  request_path        = "/healthz"
}

