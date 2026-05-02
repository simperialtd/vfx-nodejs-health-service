include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "rsg" {
  config_path = "../resource-group"
  mock_outputs = {
    resource_group = {
      "prodca" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/prodca"
        name = "prodca"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}


terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//log-analytics"
}

inputs = {
  resource_group_name             = dependency.rsg.outputs.resource_group["prodca"].name
  log_analytics_workspace_suffix  = "prodca"
}