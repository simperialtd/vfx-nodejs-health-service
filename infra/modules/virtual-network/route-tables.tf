# Following standard of having a NSG per subnet

#Naming conventions from centralized module
module "route_table_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "route_table"
}

# Route Tables
resource "azurerm_route_table" "this" {
  for_each = { for subnet in var.subnets : subnet.subnet_suffix => subnet }

  name                = "${module.route_table_naming.resource_name_prefix}-rt-${each.value.subnet_suffix}"
  location            = var.location
  resource_group_name = module.resource-group.resource_group[local.resource_group_suffix].name
}

# Routes
resource "azurerm_route" "this" {
  for_each = merge([
    for subnet in var.subnets : {
      for route in concat(coalesce(subnet.route_table_rules, []), local.default_route_table_rules[var.location]) :
      "${subnet.subnet_suffix}|${route.name}" => merge(route, { subnet_suffix = subnet.subnet_suffix })
    }
  ]...)

  name                   = each.value.name
  resource_group_name    = module.resource-group.resource_group[local.resource_group_suffix].name
  route_table_name       = azurerm_route_table.this[each.value.subnet_suffix].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address

}

# Route Table to Subnet Association
resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for subnet in var.subnets : subnet.subnet_suffix => subnet }

  subnet_id      = azurerm_subnet.this[each.value.subnet_suffix].id
  route_table_id = azurerm_route_table.this[each.value.subnet_suffix].id

}
