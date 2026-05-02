include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//virtual-network"
}

dependency "hub_vnet" {
  config_path = "../../hub/virtual-network"
  mock_outputs = {
    virtual_network = {
        resource_group_name = "rsg_name"
        name                = "vnet_name"
        id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/virtualNetworks/vnet_name" 
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

inputs = {
  vnet_name_suffix = "devca"
  vnet_address_space = ["10.1.0.0/20"]
  subnets =[
    {
      subnet_suffix     = "ca-infra"
      address_prefixes  = ["10.1.0.0/21"]
      delegation        = {
        service_name = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    },
    {
      subnet_suffix     = "ca"
      address_prefixes  = ["10.1.8.0/24"]
      nsg_rules = [{
        name                         = "AllowHTTPSFromAVD"
        protocol                     = "Tcp"
        source_port_range            = "*"
        destination_port_range       = "443"
        source_address_prefix        = "10.0.0.0/26"
        destination_address_prefix   = "*"
        access                       = "Allow"
        priority                     = 100
        direction                    = "Inbound"
        description                  = "Allow HTTPS traffic from AVD"
      }]
    }
  ]
  peered_vnets = [
    {
      remote_vnet_resource_group_name = dependency.hub_vnet.outputs.virtual_network.resource_group_name
      remote_vnet_name                = dependency.hub_vnet.outputs.virtual_network.name
      remote_vnet_id                  = dependency.hub_vnet.outputs.virtual_network.id
    }
  ] 

}