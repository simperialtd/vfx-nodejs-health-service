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

variable "vnet_name_suffix" {
  description = "Virtual network name suffix"
  type        = string
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
}

variable "dns_servers" {
  description = "List of DNS servers for the virtual network"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Map of subnets to create within the virtual network"
  type = list(object({
    subnet_suffix    = string
    address_prefixes = list(string)
    delegation = optional(object({
      service_name = string
      actions      = list(string)
    }))
    nsg_rules = optional(list(object({
      name                         = string
      protocol                     = string
      source_port_range            = string
      destination_port_range       = string
      source_address_prefix        = string
      destination_address_prefix   = string
      access                       = string
      priority                     = number
      direction                    = string
      source_port_ranges           = optional(list(string), [])
      destination_port_ranges      = optional(list(string), [])
      source_address_prefixes      = optional(list(string), [])
      destination_address_prefixes = optional(list(string), [])
      description                  = string
    })))
    route_table_rules = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })))
  }))
}

variable "peered_vnets" {
  description = "List of virtual networks to peer with"
  type = list(object({
    remote_vnet_resource_group_name = string
    remote_vnet_name                = string
    remote_vnet_id                  = string
    allow_virtual_network_access    = optional(bool, true)
    allow_forwarded_traffic         = optional(bool, false)
    allow_gateway_transit           = optional(bool, false)
    use_remote_gateways             = optional(bool, false)
  }))
  default = []
}
