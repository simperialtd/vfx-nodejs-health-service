# Following standard of having a NSG per subnet

# Naming conventions from centralized module
module "nsg_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "network_security_group"
}

# Network Security Groups
resource "azurerm_network_security_group" "this" {
  for_each = { for subnet in var.subnets : subnet.subnet_suffix => subnet }

  name                = "${module.nsg_naming.resource_name_prefix}-${each.value.subnet_suffix}"
  location            = var.location
  resource_group_name = module.resource-group.resource_group[local.resource_group_suffix].name
}

# NSG to Subnet Association
resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for subnet in var.subnets : subnet.subnet_suffix => subnet }

  subnet_id                 = azurerm_subnet.this[each.value.subnet_suffix].id
  network_security_group_id = azurerm_network_security_group.this[each.value.subnet_suffix].id

}

# Network Security Rules
resource "azurerm_network_security_rule" "this" {
  for_each = merge([
    for subnet in var.subnets : {
      for rule in concat(coalesce(subnet.nsg_rules, []), local.default_nsg_rules) :
      "${subnet.subnet_suffix}|${rule.name}" => merge(rule, { subnet_suffix = subnet.subnet_suffix })
    }
  ]...)

  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_suffix].name
  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  description                 = each.value.description
  resource_group_name         = module.resource-group.resource_group[local.resource_group_suffix].name

  source_port_range  = length(try(each.value.source_port_ranges, [])) == 0 ? each.value.source_port_range : null
  source_port_ranges = length(try(each.value.source_port_ranges, [])) > 0 ? each.value.source_port_ranges : null

  destination_port_range  = length(try(each.value.destination_port_ranges, [])) == 0 ? each.value.destination_port_range : null
  destination_port_ranges = length(try(each.value.destination_port_ranges, [])) > 0 ? each.value.destination_port_ranges : null

  source_address_prefix   = length(try(each.value.source_address_prefixes, [])) == 0 ? each.value.source_address_prefix : null
  source_address_prefixes = length(try(each.value.source_address_prefixes, [])) > 0 ? each.value.source_address_prefixes : null

  destination_address_prefix   = length(try(each.value.destination_address_prefixes, [])) == 0 ? each.value.destination_address_prefix : null
  destination_address_prefixes = length(try(each.value.destination_address_prefixes, [])) > 0 ? each.value.destination_address_prefixes : null
}