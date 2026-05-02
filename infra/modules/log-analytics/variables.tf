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

variable "log_analytics_workspace_suffix" {
  description = "Suffix for the Log Analytics Workspace name"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "sku" {
  description = "SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period in days"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB"
  type        = number
  default     = -1
}

variable "internet_ingestion_enabled" {
  description = "Whether internet ingestion is enabled"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Whether internet query is enabled"
  type        = bool
  default     = true
}

variable "local_authentication_enabled" {
  description = "Whether local authentication is enabled"
  type        = bool
  default     = true
}

variable "cmk_for_query_forced" {
  description = "Whether CMK for query is forced"
  type        = bool
  default     = false
}

