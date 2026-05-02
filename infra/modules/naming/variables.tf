variable "company_code" {
  description = "Company code"
  type        = string
  validation {
    condition     = length(var.company_code) > 0 && length(var.company_code) <= 3
    error_message = "Company code cannot be empty and must be at most 3 characters."
  }
  default = "si"
}

variable "environment" {
  description = "Environment name (e.g., 'dev', 'preprod', 'prod')"
  type        = string
  validation {
    condition     = contains(["hub", "sbx", "dev", "test", "preprod", "prod"], var.environment)
    error_message = "Environment must be one of: hub, sbx, dev, test, preprod or prod"
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  validation {
    condition     = contains(["westeurope", "eastus", "uksouth"], var.location)
    error_message = "Location must be one of: westeurope, eastus or uksouth."
  }
}

variable "resource_type" {
  description = "Resource type"
  type        = string
  validation {
    condition     = contains(["resource_group", "virtual_network", "subnet", "network_security_group", "network-interface", "public_ip", "route_table", "virtual_machine", "avd_host_pool", "avd_desktop_workspace", "avd_desktop_application_group", "container_registry", "container_apps_environment", "container_app", "osdisk", "log_analytics_workspace", "key_vault", "user_assigned_identity", "private_endpoint"], var.resource_type)
    error_message = "Resource type must be one of: resource_group, virtual_network, subnet, network_security_group, network-interface, public_ip, route_table, virtual_machine, avd_host_pool, avd_desktop_workspace, avd_desktop_application_group, container_registry, container_apps_environment, container_app, osdisk, log_analytics_workspace, key_vault, private_endpoint or user_assigned_identity."
  }
}

