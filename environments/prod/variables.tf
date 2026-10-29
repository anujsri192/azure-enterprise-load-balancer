variable "environment" {
  description = "Target deployment environment."
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "enterprise-lb"
}

variable "tags" {
  description = "Standard corporate resource tags."
  type        = map(string)
  default = {
    Environment  = "Production"
    ManagedBy    = "Terraform"
    Architecture = "High-Availability-Standard-LB"
    Owner        = "Anuj Srivastava"
  }
}
