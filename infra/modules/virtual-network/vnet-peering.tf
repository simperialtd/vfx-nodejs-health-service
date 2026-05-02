resource "azurerm_virtual_network_peering" "local" {
  for_each = { for peer_vnet in var.peered_vnets : peer_vnet.remote_vnet_name => peer_vnet }

  name                 = "peering-${each.value.remote_vnet_name}"
  resource_group_name  = module.resource-group.resource_group[local.resource_group_suffix].name
  virtual_network_name = azurerm_virtual_network.this.name

  remote_virtual_network_id = each.value.remote_vnet_id

  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "remote" {
  for_each = { for peer_vnet in var.peered_vnets : peer_vnet.remote_vnet_name => peer_vnet }

  name                 = "peering-${azurerm_virtual_network.this.name}"
  resource_group_name  = each.value.remote_vnet_resource_group_name
  virtual_network_name = each.value.remote_vnet_name

  remote_virtual_network_id = azurerm_virtual_network.this.id

  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}