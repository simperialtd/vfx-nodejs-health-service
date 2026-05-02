# Naming conventions from centralized module
module "vnet_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "virtual_network"
}

module "subnet_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "subnet"
}

# Resource Group with net suffix is used for Virtual Network and related resources (e.g., subnets, NSGs)
module "resource-group" {
  source = "../resource-group"

  environment              = var.environment
  location                 = var.location
  resource_groups_suffixes = [local.resource_group_suffix]
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = "${module.vnet_naming.resource_name_prefix}-${var.vnet_name_suffix}"
  location            = var.location
  resource_group_name = module.resource-group.resource_group[local.resource_group_suffix].name
  address_space       = var.vnet_address_space
  dns_servers         = var.dns_servers
}

# Subnets
resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.subnet_suffix => subnet }

  name                 = "${module.subnet_naming.resource_name_prefix}-${each.value.subnet_suffix}"
  resource_group_name  = module.resource-group.resource_group[local.resource_group_suffix].name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [each.value.delegation] : []
    content {
      name = "delegation"
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}
