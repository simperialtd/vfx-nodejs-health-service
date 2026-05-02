include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//user-assigned-identity"
}

dependency "rsg" {
  config_path = "../resource-group"
  mock_outputs = {
    resource_group = {
      "uai" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/uai"
        name = "uai"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

inputs = {
  resource_group_name = dependency.rsg.outputs.resource_group["uai"].name
  identity_suffixes = [
    "devca",
    "prodca"
  ]
}