variable "name" {
  description = "Name of the Azure Load Balancer."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "location" {
  description = "Azure region where the Load Balancer will be deployed."
  type        = string
}

variable "sku" {
  description = "SKU of the Load Balancer. Defaults to Standard."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Gateway"], var.sku)
    error_message = "sku must be either 'Standard' or 'Gateway'."
  }
}

variable "type" {
  description = "Type of load balancer: Public or Internal."
  type        = string
  default     = "Public"

  validation {
    condition     = contains(["Public", "Internal"], var.type)
    error_message = "type must be either 'Public' or 'Internal'."
  }
}

variable "frontend_ip_configurations" {
  description = <<EOF
List of frontend IP configurations. Uses dynamic blocks.
- name: string
- public_ip_address_id: optional public IP ID (for Public LB)
- subnet_id: optional subnet ID (for Internal LB)
- private_ip_address: optional static private IP (for Internal LB)
- private_ip_address_allocation: "Dynamic" or "Static"
- zones: optional list of availability zones (e.g. ["1", "2", "3"])
EOF
  type = list(object({
    name                          = string
    public_ip_address_id          = optional(string)
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string, "Dynamic")
    zones                         = optional(list(string))
  }))
}

variable "backend_pools" {
  description = "List of backend address pool names to create."
  type        = list(string)
  default     = ["bep-app-pool"]
}

variable "probes" {
  description = <<EOF
Map of health probes.
Key is the probe name.
EOF
  type = map(object({
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number, 15)
    number_of_probes    = optional(number, 2)
  }))
  default = {}
}

variable "lb_rules" {
  description = <<EOF
Map of Load Balancing rules.
Key is the rule name.
EOF
  type = map(object({
    frontend_ip_configuration_name = string
    backend_address_pool_name      = string
    probe_name                     = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    idle_timeout_in_minutes        = optional(number, 4)
    enable_floating_ip             = optional(bool, false)
    enable_tcp_reset               = optional(bool, true)
    disable_outbound_snat          = optional(bool, false)
  }))
  default = {}
}

variable "outbound_rules" {
  description = <<EOF
Map of Outbound SNAT rules for Public Standard Load Balancers.
Key is the outbound rule name.
EOF
  type = map(object({
    frontend_ip_configuration_names = list(string)
    backend_address_pool_name       = string
    protocol                        = string
    allocated_outbound_ports        = optional(number, 1024)
    idle_timeout_in_minutes         = optional(number, 4)
    enable_tcp_reset                = optional(bool, true)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all Load Balancer resources."
  type        = map(string)
  default     = {}
}

