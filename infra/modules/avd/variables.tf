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
  description = "AVD Host Pool resource group name"
  type        = string
}

variable "avd_host_pool_suffix" {
  description = "AVD Host Pool name suffix"
  type        = string
}

variable "avd_host_pool_description" {
  description = "AVD Host Pool description"
  type        = string
  default     = "AVD Host Pool deployed by Terraform"
}

variable "avd_host_pool_type" {
  description = "AVD Host Pool type"
  type        = string
  default     = "Pooled"
}

variable "maximum_sessions_allowed" {
  description = "Maximum sessions allowed per user"
  type        = number
}

variable "validate_environment" {
  description = "Whether to validate the environment"
  type        = bool
  default     = false
}

variable "load_balancer_type" {
  description = "AVD Load balancer type"
  type        = string
  default     = "BreadthFirst"
  validation {
    condition     = contains(["BreadthFirst", "DepthFirst"], var.load_balancer_type)
    error_message = "Load balancer type must be either 'BreadthFirst' or 'DepthFirst'."
  }
}

variable "custom_rdp_properties" {
  description = "Custom RDP properties for AVD"
  type        = string
  default     = "drivestoredirect:s:;usbdevicestoredirect:s:;redirectclipboard:i:0;redirectprinters:i:0;audiomode:i:0;videoplaybackmode:i:1;devicestoredirect:s:*;redirectcomports:i:1;redirectsmartcards:i:1;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;targetisaadjoined:i:1;enablerdsaadauth:i:1;"
}

variable "start_vm_on_connect" {
  description = "Whether to start VM on connect"
  type        = bool
  default     = false
}

variable "avd_host_pool_public_network_access" {
  description = "AVD Host Pool Public Access"
  type        = string
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Disabled", "EnabledForClientsOnly", "EnabledForSessionHostsOnly"], var.avd_host_pool_public_network_access)
    error_message = "Host Pool Public Access must be one of: 'Enabled', 'Disabled', 'EnabledForClientsOnly', 'EnabledForSessionHostsOnly'."

  }
}

variable "preferred_app_group_type" {
  description = "AVD Host Pool Public Access"
  type        = string
  default     = "Desktop"
  validation {
    condition     = contains(["Desktop", "RemoteApp"], var.preferred_app_group_type)
    error_message = "Preferred app group type must be either 'Desktop' or 'RemoteApp'."

  }
}

variable "workspace_suffix" {
  description = "AVD Workspace name suffix"
  type        = string
}

variable "workspace_public_network_access" {
  description = "AVD Workspace Public Network Access"
  type        = bool
  default     = true
}

variable "application_groups" {
  description = "AVD Application Groups"
  type = list(object({
    suffix                       = string
    default_desktop_display_name = string
    description                  = string
    friendly_name                = string
    assignment_principal_ids     = list(string) # List of user principal ids to assign to the application group
  }))
}

variable "number_of_session_hosts" {
  description = "Number of session hosts"
  type        = number
}

variable "session_hosts_resource_group_name" {
  description = "AVD Host Pool resource group name"
  type        = string
}

variable "session_hosts_resource_group_id" {
  description = "AVD Host Pool resource group id"
  type        = string
}

variable "session_hosts_preffix" {
  description = "AVD Host Pool name preffix"
  type        = string
}

variable "session_hosts_subnet_id" {
  description = "AVD Host Pool subnet id"
  type        = string
}

variable "session_hosts_vm_size" {
  description = "AVD Host Pool VM size"
  type        = string
}

variable "session_hosts_local_admin_username" {
  description = "AVD Host Pool local admin username"
  type        = string
  default     = "localadmin"
}

variable "session_hosts_source_image_reference" {
  description = "AVD Host Pool source image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "microsoftwindowsdesktop"
    offer     = "windows-11"
    sku       = "win11-24h2-avd"
    version   = "latest"
  }
}

