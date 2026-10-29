/**
 * # Enterprise Azure Load Balancer Module
 * 
 * Provisions an Azure Standard Load Balancer (Public or Internal) with:
 * - Dynamic frontend_ip_configuration blocks (supporting multi-IP & multi-AZ)
 * - Map-based health probes (HTTP/HTTPS/TCP)
 * - Map-based load balancing rules with TCP reset & floating IP options
 * - Dynamic outbound SNAT rules for secure egress
 */

resource "azurerm_lb" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags

  # ------------------------------------------------------------------------------------------------
  # Dynamic Frontend IP Configuration
  # ------------------------------------------------------------------------------------------------
  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                          = frontend_ip_configuration.value.name
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id
      subnet_id                     = frontend_ip_configuration.value.subnet_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
      zones                         = frontend_ip_configuration.value.zones
    }
  }
}

# --------------------------------------------------------------------------------------------------
# Backend Address Pools
# --------------------------------------------------------------------------------------------------
resource "azurerm_lb_backend_address_pool" "this" {
  for_each = toset(var.backend_pools)

  name            = each.value
  loadbalancer_id = azurerm_lb.this.id
}

# --------------------------------------------------------------------------------------------------
# Health Probes: for_each iteration over probe specifications
# --------------------------------------------------------------------------------------------------
resource "azurerm_lb_probe" "this" {
  for_each = var.probes

  name                = each.key
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = each.value.protocol
  port                = each.value.port
  request_path        = each.value.protocol != "Tcp" ? each.value.request_path : null
  interval_in_seconds = each.value.interval_in_seconds
  number_of_probes    = each.value.number_of_probes
}

# --------------------------------------------------------------------------------------------------
# Load Balancing Rules: for_each iteration mapping frontend, backend, and health probes
# --------------------------------------------------------------------------------------------------
resource "azurerm_lb_rule" "this" {
  for_each = var.lb_rules

  name                           = each.key
  loadbalancer_id                = azurerm_lb.this.id
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_name].id]
  probe_id                       = azurerm_lb_probe.this[each.value.probe_name].id
  idle_timeout_in_minutes        = each.value.idle_timeout_in_minutes
  enable_floating_ip             = each.value.enable_floating_ip
  enable_tcp_reset               = each.value.enable_tcp_reset
  disable_outbound_snat          = each.value.disable_outbound_snat
}

# --------------------------------------------------------------------------------------------------
# Outbound Rules (SNAT for Public Load Balancers)
# --------------------------------------------------------------------------------------------------
resource "azurerm_lb_outbound_rule" "this" {
  for_each = var.outbound_rules

  name                     = each.key
  loadbalancer_id          = azurerm_lb.this.id
  backend_address_pool_id  = azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_name].id
  protocol                 = each.value.protocol
  allocated_outbound_ports = each.value.allocated_outbound_ports
  idle_timeout_in_minutes  = each.value.idle_timeout_in_minutes
  enable_tcp_reset         = each.value.enable_tcp_reset

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration_names
    content {
      name = frontend_ip_configuration.value
    }
  }
}

