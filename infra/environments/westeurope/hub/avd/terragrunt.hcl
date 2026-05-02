include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "rsg" {
  config_path = "../resource-group"
  mock_outputs = {
    resource_group = {
      "avd" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/avd"
        name = "avd"
      },
       "avd-session-hosts" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/avd-session-hosts"
        name = "avd-session-hosts"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "vnet" {
  config_path = "../virtual-network"
  mock_outputs = {
    subnets = {
      "avd" = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/virtualNetworks/vnet_name/subnets/avd"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//avd"
}


inputs = {
  resource_group_name               = dependency.rsg.outputs.resource_group["avd"].name
  avd_host_pool_suffix              = "hub-avd"
  avd_host_pool_description         = "Host pool to allow private access to environment"
  avd_host_pool_type                = "Pooled"
  load_balancer_type                = "BreadthFirst"
  maximum_sessions_allowed          = 2
  workspace_suffix                  = "hub-avd"
  number_of_session_hosts           = 1
  session_hosts_resource_group_name = dependency.rsg.outputs.resource_group["avd-session-hosts"].name
  session_hosts_resource_group_id   = dependency.rsg.outputs.resource_group["avd-session-hosts"].id
  session_hosts_preffix             = "siavdss"
  session_hosts_subnet_id           = dependency.vnet.outputs.subnets["avd"].id
  session_hosts_vm_size             = "Standard_D2s_v6"
  application_groups = [{
    suffix                       = "hub-avd"
    default_desktop_display_name = "Hub AVD"
    description                  = "Hub AVD Application Group"
    friendly_name                = "Hub AVD"
    assignment_principal_ids     = ["ead19779-2807-4e31-95f9-84ab123d3e7c"]
  }]
}