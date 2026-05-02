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
  description = "Name of the resource group where the container apps will be deployed"
  type        = string
}

variable "container_apps_environment_name_suffix" {
  description = "Container Apps Environment name suffix"
  type        = string
}

variable "infrastructure_subnet_id" {
  description = "Subnet ID for the Container Apps Environment infrastructure"
  type        = string
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled for the Container Apps Environment"
  type        = bool
  default     = false
}

variable "workload_profiles" {
  description = "Additional workload profiles besides the default Consumption profile"
  type = list(object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number, 0)
    maximum_count         = optional(number, 1)
  }))
  default = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace customer ID (workspace ID) for container app environment logs"
  type        = string
  default     = null
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
}

variable "mutual_tls_enabled" {
  description = "Whether mutual TLS is enabled for the Container Apps Environment"
  type        = bool
  default     = false
}

variable "dapr_application_insights_connection_string" {
  description = "Application Insights connection string for Dapr"
  type        = string
  default     = null
}

variable "image_tag" {
  description = "The container image tag to deploy"
  type        = string
  default     = "latest"
}

variable "container_apps" {
  description = "List of Container Apps to deploy"
  type = list(object({
    name_suffix                      = string
    container_registry_login_server  = string
    image                            = string
    cpu                              = optional(number, 0.5)
    memory                           = optional(string, "1Gi")
    args                             = optional(list(string))
    command                          = optional(list(string))
    transport                        = optional(string, "auto") # auto, http, http2, tcp
    target_port                      = number
    exposed_port                     = optional(number) # Only for tcp transport
    client_certificate_mode          = optional(string)
    allow_insecure_connections       = optional(bool, false)
    min_replicas                     = optional(number, 1)
    max_replicas                     = optional(number, 2)
    termination_grace_period_seconds = optional(number)
    cooldown_period_in_seconds       = optional(number)
    polling_interval_in_seconds      = optional(number)
    workload_profile_name            = optional(string)
    revision_mode                    = optional(string, "Single")
    revision_suffix                  = optional(string)
    max_inactive_revisions           = optional(number)
    user_assigned_identity_id        = optional(string)
    cors = optional(object({
      allowed_origins           = list(string)
      allow_credentials_enabled = optional(bool, false)
      allowed_headers           = optional(list(string))
      allowed_methods           = optional(list(string))
      exposed_headers           = optional(list(string))
      max_age_in_seconds        = optional(number)
    }))
    ip_security_restrictions = optional(list(object({
      name             = string
      action           = string # Allow or Deny
      ip_address_range = string
      description      = optional(string)
    })), [])
    dapr = optional(object({
      app_id       = string
      app_port     = optional(number)
      app_protocol = optional(string, "http")
    }))
    volumes = optional(list(object({
      name          = string
      storage_type  = optional(string, "EmptyDir") # AzureFile, EmptyDir, NfsAzureFile, Secret
      storage_name  = optional(string)
      mount_options = optional(string)
    })), [])
    volume_mounts = optional(list(object({
      name     = string
      path     = string
      sub_path = optional(string)
    })), [])
    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })), [])
    liveness_probe = optional(object({
      transport               = string
      port                    = number
      initial_delay           = optional(number, 1)
      interval_seconds        = optional(number, 10)
      timeout                 = optional(number, 1)
      failure_count_threshold = optional(number, 3)
      path                    = optional(string, "/")
      host                    = optional(string)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
    readiness_probe = optional(object({
      transport               = string
      port                    = number
      initial_delay           = optional(number, 0)
      interval_seconds        = optional(number, 10)
      timeout                 = optional(number, 1)
      success_count_threshold = optional(number, 3)
      failure_count_threshold = optional(number, 3)
      path                    = optional(string, "/")
      host                    = optional(string)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
    startup_probe = optional(object({
      transport               = string
      port                    = number
      initial_delay           = optional(number, 0)
      interval_seconds        = optional(number, 10)
      timeout                 = optional(number, 1)
      failure_count_threshold = optional(number, 3)
      path                    = optional(string, "/")
      host                    = optional(string)
      headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
    secrets = optional(list(object({
      name                = string
      value               = optional(string)
      key_vault_secret_id = optional(string)
      identity            = optional(string)
    })), [])
    traffic_weights = optional(list(object({
      label           = optional(string)
      latest_revision = optional(bool)
      revision_suffix = optional(string)
      percentage      = number
    })), [])
    http_scaling_rules = optional(list(object({
      name                = string
      concurrent_requests = number
      authentication = optional(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })), [])
    tcp_scaling_rules = optional(list(object({
      name                = string
      concurrent_requests = number
      authentication = optional(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })), [])
    azure_queue_scaling_rules = optional(list(object({
      name         = string
      queue_name   = string
      queue_length = number
      authentication = object({
        secret_name       = string
        trigger_parameter = string
      })
    })), [])
    custom_scaling_rules = optional(list(object({
      name        = string
      type        = string
      metadata    = map(string)
      identity_id = optional(string)
      authentication = optional(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })), [])
  }))
}


