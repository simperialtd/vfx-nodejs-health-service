# Private DNS Zones
resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.zone_types)

  name                = local.dns_zone_map[each.key]
  resource_group_name = var.resource_group_name
}

# Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = toset(var.zone_types)

  name                  = "vnet-link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
}
