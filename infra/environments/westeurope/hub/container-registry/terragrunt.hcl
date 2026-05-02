locals {
  env_vars            = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  app_registration_id = local.env_vars.locals.app_registration_id
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "rsg" {
  config_path = "../resource-group"
  mock_outputs = {
    resource_group = {
      "cr" = {
        id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/cr"
        name = "cr"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "vnet" {
  config_path = "../virtual-network"
  mock_outputs = {
    subnets = {
      "cr" = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/virtualNetworks/vnet_name/subnets/cr"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "dns-zone" {
  config_path = "../dns-zones"
  mock_outputs = {
    private_dns_zones = {
      "container_registry" = {
        name = "dns_zone_name"
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/privateDnsZones/dns_zone"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "user-assigned-identity" {
  config_path = "../user-assigned-identity"
  mock_outputs = {
    user_assigned_identity = {
      "devca" = {
        principal_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.ManagedIdentity/userAssignedIdentities/devca"
      },
      "prodca" = {
        principal_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.ManagedIdentity/userAssignedIdentities/prodca"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//container-registry"
}

inputs = {
  resource_group_name             = dependency.rsg.outputs.resource_group["cr"].name
  acr_name_suffix                 = "hub"
  sku                             = "Premium"
  #Public Networks Access enabled until we deploy a GitHub agent
  public_network_access_enabled   = true
  zone_redundancy_enabled         = true
  private_endpoint_subnet_id      = dependency.vnet.outputs.subnets["cr"].id
  private_dns_zone_id             = dependency.dns-zone.outputs.private_dns_zones["container_registry"].id
  repository_writer_principal_ids = [local.app_registration_id]
  repository_reader_principal_ids = [
    dependency["user-assigned-identity"].outputs.user_assigned_identity["devca"].principal_id,
    dependency["user-assigned-identity"].outputs.user_assigned_identity["prodca"].principal_id
  ]
}