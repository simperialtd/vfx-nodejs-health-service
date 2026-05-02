output "resource_group" {
  description = "Resource group details (id and name)"
  value = {
    for suffix in toset(var.resource_groups_suffixes) : suffix => {
      id   = azurerm_resource_group.this[suffix].id
      name = azurerm_resource_group.this[suffix].name
    }
  }
}