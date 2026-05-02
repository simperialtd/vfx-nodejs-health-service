include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "rsg" {
  config_path = "../resource-group"
  mock_outputs = {
    resource_group = {
      "devca" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/devca"
        name = "devca"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}


terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//log-analytics"
}

inputs = {
  resource_group_name             = dependency.rsg.outputs.resource_group["devca"].name
  log_analytics_workspace_suffix  = "devca"
}