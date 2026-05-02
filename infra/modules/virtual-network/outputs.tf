output "virtual_network" {
  description = "Virtual network details (id and name)"
  value = {
    resource_group_name = module.resource-group.resource_group[local.resource_group_suffix].name
    id                  = azurerm_virtual_network.this.id
    name                = azurerm_virtual_network.this.name
  }
}

output "subnets" {
  description = "Subnets details (id and name)"
  value = {
    for subnet in var.subnets : subnet.subnet_suffix => {
      id   = azurerm_subnet.this[subnet.subnet_suffix].id
      name = azurerm_subnet.this[subnet.subnet_suffix].name
    }
  }
}