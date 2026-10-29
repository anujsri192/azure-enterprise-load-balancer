output "resource_group_name" {
  description = "Resource group name."
  value       = azurerm_resource_group.this.name
}

output "public_lb_id" {
  description = "The ID of the External Public Load Balancer."
  value       = module.public_load_balancer.id
}

output "public_ip_address" {
  description = "The Public IP address fronting the External Load Balancer."
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "internal_lb_id" {
  description = "The ID of the Internal Microservice Load Balancer."
  value       = module.internal_load_balancer.id
}

output "internal_lb_private_ip" {
  description = "Private IP of the Internal Load Balancer frontend."
  value       = "10.200.1.10"
}

