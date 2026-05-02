locals {
  resource_group_suffix = "net"

  #Default route table rules per region to be added to all subnets, see commented example
  default_route_table_rules = {
    westeurope = [
      #{
      #  name                   = "DCSDefaultRoute"
      #  address_prefix         = "0.0.0.0/0"
      #  next_hop_type          = "VirtualAppliance"
      #  next_hop_in_ip_address = "x.x.x.x"
      #}
    ]
  }


  # Default NSG rules to be applied to all subnets
  default_nsg_rules = tolist([
    {
      name                       = "Deny_Inbound_Rule"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      access                     = "Deny"
      priority                   = 4096
      direction                  = "Inbound"
      description                = "Default Deny Inbound Rule"
    }
  ])


}