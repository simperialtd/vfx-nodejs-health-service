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

dependency "vnet" {
  config_path = "../virtual-network"
  mock_outputs = {
    subnets = {
      "ca-infra" = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/virtualNetworks/vnet_name/subnets/ca-infra"
      },
      "ca" = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/virtualNetworks/vnet_name/subnets/ca"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "log-analytics" {
  config_path = "../log-analytics"
  mock_outputs = {
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/devca/providers/Microsoft.OperationalInsights/workspaces/devca"
  }
}

dependency "acr" {
  config_path = "../../hub/container-registry"
  mock_outputs = {
    container_registry = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.ContainerRegistry/registries/acr_name"
      name         = "acr_name"
      login_server = "acr_name.azurecr.io"
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

dependency "user_assigned_identity" {
  config_path = "../../hub/user-assigned-identity"
  mock_outputs = {
    user_assigned_identity = {
      "devca" = {
        id = "/subbscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_nameproviders/Microsoft.ManagedIdentity/userAssignedIdentities/devca"
      }
    }
  }
}
dependency "dns-zone" {
  config_path = "../../hub/dns-zones"
  mock_outputs = {
    private_dns_zones = {
      "container_app" = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rsg_name/providers/Microsoft.Network/privateDnsZones/container_app"
      }
    }
  }
  mock_outputs_merge_strategy_with_state = "deep_map_only"
}

terraform {
  source = "${get_parent_terragrunt_dir()}/../modules//container-apps"
}

inputs = {
  resource_group_name                    = dependency.rsg.outputs.resource_group["devca"].name
  container_apps_environment_name_suffix = "devca"
  infrastructure_subnet_id               = dependency.vnet.outputs.subnets["ca-infra"].id
  zone_redundancy_enabled                = true
  log_analytics_workspace_id             = dependency["log-analytics"].outputs.log_analytics_workspace_id
  private_endpoint_subnet_id             = dependency.vnet.outputs.subnets["ca"].id
  private_dns_zone_id                    = dependency.dns-zone.outputs.private_dns_zones["container_app"].id
  container_apps                         = [{
      name_suffix   = "nodejshs"
      container_registry_login_server = dependency.acr.outputs.container_registry.login_server
      image         = "${dependency.acr.outputs.container_registry.login_server}/nodejs-health-service"
      cpu           = 0.5
      memory        = "1Gi"
      min_replicas  = 1
      max_replicas  = 1
      target_port   = 8080
      workload_profile_name = "Consumption"
      user_assigned_identity_id = dependency["user_assigned_identity"].outputs.user_assigned_identity["devca"].id
      env = [
        {
          name  = "APP_ENVIRONMENT"
          value = "dev"
        }
      ]
      liveness_probe = {
        transport     = "HTTP"
        port          = 8080
        path          = "/health"
      }
      startup_probe = {
        transport     = "HTTP"
        port          = 8080
        path          = "/health"
      }
      readiness_probe = {
        transport     = "HTTP"
        port          = 8080
        path          = "/health"
      }
  }]
}





