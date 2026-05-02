include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "rsg" {
  config_path = "../resource-group"
  mock_outputs = {
    resource_group = {
      "dns" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/dns"
        name = "dns"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "vnet" {
  config_path = "../virtual-network"
  mock_outputs = {
    virtual_network = {
        name = "vnet_name"
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/virtualNetworks/vnet_name" 
    }
  }
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//private-dns-zone"
}


inputs = {
  resource_group_name = dependency.rsg.outputs.resource_group["dns"].name
  zone_types          = ["container_registry", "container_app"]
  virtual_network_id  = dependency.vnet.outputs.virtual_network.id
}