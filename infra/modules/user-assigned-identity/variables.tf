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
  description = "Name of the resource group where the user-assigned identities will be deployed"
  type        = string
}

variable "identity_suffixes" {
  description = "List of suffixes for the user-assigned identity names"
  type        = list(string)
}
