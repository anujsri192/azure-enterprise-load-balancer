/**
 * # Production Enterprise Load Balancing Suite (Parent / Root Module)
 * 
 * Demonstrates:
 * 1. External Public Standard Load Balancer with Zone-Redundant Public IP & Outbound SNAT
 * 2. Internal Microservice Standard Load Balancer with private IP frontend
 * 3. Health Probes (TCP & HTTP) and Load Balancing Rules
 * 4. Centralized Monitoring & Diagnostic Settings
 */

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

# --------------------------------------------------------------------------------------------------
# Resource Group
# --------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = var.tags
}

# --------------------------------------------------------------------------------------------------
# Supporting Networking (VNet & Subnets for backend integration)
# --------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.200.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "frontend" {
  name                 = "snet-internal-lb"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.200.1.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "snet-workloads"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.200.2.0/24"]
}

# --------------------------------------------------------------------------------------------------
# Zone-Redundant Public IP for External Load Balancer
# --------------------------------------------------------------------------------------------------
resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-${local.name_prefix}-public-lb"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags                = var.tags
}

# --------------------------------------------------------------------------------------------------
# 1. External Public Standard Load Balancer
# --------------------------------------------------------------------------------------------------
module "public_load_balancer" {
  source = "../../modules/load_balancer"

  name                = "lbe-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  type                = "Public"

  frontend_ip_configurations = [
    {
      name                 = "fe-public-internet"
      public_ip_address_id = azurerm_public_ip.lb_pip.id
      zones                = ["1", "2", "3"]
    }
  ]

  backend_pools = ["bep-web-pool"]

  probes = {
    "hp-https-443" = {
      protocol            = "Https"
      port                = 443
      request_path        = "/healthz"
      interval_in_seconds = 10
      number_of_probes    = 2
    }
  }

  lb_rules = {
    "lbr-https-traffic" = {
      frontend_ip_configuration_name = "fe-public-internet"
      backend_address_pool_name      = "bep-web-pool"
      probe_name                     = "hp-https-443"
      protocol                       = "Tcp"
      frontend_port                  = 443
      backend_port                   = 443
      enable_tcp_reset               = true
      idle_timeout_in_minutes        = 15
    }
  }

  outbound_rules = {
    "outbound-snat-rule" = {
      frontend_ip_configuration_names = ["fe-public-internet"]
      backend_address_pool_name       = "bep-web-pool"
      protocol                        = "All"
      allocated_outbound_ports        = 2048
      idle_timeout_in_minutes         = 10
      enable_tcp_reset                = true
    }
  }

  tags = var.tags
}

# --------------------------------------------------------------------------------------------------
# 2. Internal Microservice Standard Load Balancer (Private IP)
# --------------------------------------------------------------------------------------------------
module "internal_load_balancer" {
  source = "../../modules/load_balancer"

  name                = "lbi-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Standard"
  type                = "Internal"

  frontend_ip_configurations = [
    {
      name                          = "fe-internal-core"
      subnet_id                     = azurerm_subnet.frontend.id
      private_ip_address            = "10.200.1.10"
      private_ip_address_allocation = "Static"
      zones                         = ["1", "2", "3"]
    }
  ]

  backend_pools = ["bep-api-tier"]

  probes = {
    "hp-api-health" = {
      protocol            = "Http"
      port                = 8080
      request_path        = "/api/v1/health"
      interval_in_seconds = 15
      number_of_probes    = 2
    }
  }

  lb_rules = {
    "lbr-internal-api" = {
      frontend_ip_configuration_name = "fe-internal-core"
      backend_address_pool_name      = "bep-api-tier"
      probe_name                     = "hp-api-health"
      protocol                       = "Tcp"
      frontend_port                  = 80
      backend_port                   = 8080
      enable_tcp_reset               = true
    }
  }

  tags = var.tags
}

