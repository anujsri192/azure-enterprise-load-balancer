output "id" {
  description = "The ID of the Load Balancer."
  value       = azurerm_lb.this.id
}

output "name" {
  description = "The name of the Load Balancer."
  value       = azurerm_lb.this.name
}

output "frontend_ip_configurations" {
  description = "Map of frontend IP configuration names to their generated IDs."
  value       = { for fic in azurerm_lb.this.frontend_ip_configuration : fic.name => fic.id }
}

output "backend_pool_ids" {
  description = "Map of backend address pool names to their resource IDs."
  value       = { for k, v in azurerm_lb_backend_address_pool.this : k => v.id }
}

output "probe_ids" {
  description = "Map of health probe names to their resource IDs."
  value       = { for k, v in azurerm_lb_probe.this : k => v.id }
}

output "rule_ids" {
  description = "Map of load balancing rule names to their resource IDs."
  value       = { for k, v in azurerm_lb_rule.this : k => v.id }
}

