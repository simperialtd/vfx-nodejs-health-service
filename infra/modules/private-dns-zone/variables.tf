variable "environment" {
  description = "Environment name (e.g., 'dev', 'preprod', 'prod')"
  type        = string
  validation {
    condition     = contains(["sbx", "dev", "test", "preprod", "prod"], var.environment)
    error_message = "Environment must be one of: sbx, dev, test, preprod or prod"
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

variable "resource_group_name" {
  description = "Name of the resource group where the private DNS zones will be deployed"
  type        = string
}

variable "zone_types" {
  description = "List of resource types to create private DNS zones for"
  type        = list(string)
  validation {
    condition = alltrue([
      for zone in var.zone_types : contains([
        "blob",
        "file",
        "queue",
        "table",
        "dfs",
        "web",
        "container_registry",
        "container_app",
        "key_vault",
        "sql_server",
        "cosmos_db",
        "service_bus",
        "event_hub",
        "app_service",
        "cognitive_services",
        "aks",
        "redis_cache",
        "monitor"
      ], zone)
    ])
    error_message = "Zone types must be one of: blob, file, queue, table, dfs, web, container_registry, container_app, key_vault, sql_server, cosmos_db, service_bus, event_hub, app_service, cognitive_services, aks, redis_cache or monitor."
  }
}

variable "virtual_network_id" {
  description = "Virtual network ID to link to the private DNS zones"
  type        = string
}
