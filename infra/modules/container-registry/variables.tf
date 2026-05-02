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

variable "resource_group_name" {
  description = "Name of the resource group where the container registry will be deployed"
  type        = string
}

variable "acr_name_suffix" {
  description = "Container registry name suffix"
  type        = string
}

variable "sku" {
  description = "SKU tier for the container registry"
  type        = string
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard or Premium."
  }
}

variable "admin_enabled" {
  description = "Whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed"
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled"
  type        = bool
  default     = false
}

variable "georeplications" {
  description = "List of geo-replication configurations"
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default = []
}

variable "retention_policy_days" {
  description = "Number of days to retain untagged manifests"
  type        = number
  default     = 7
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
}

variable "repository_writer_principal_ids" {
  description = "List of principal IDs to assign the Container Registry Repository Writer role"
  type        = list(string)
  default     = []
}

variable "repository_reader_principal_ids" {
  description = "List of principal IDs to assign the Container Registry Repository Reader role"
  type        = list(string)
  default     = []
}