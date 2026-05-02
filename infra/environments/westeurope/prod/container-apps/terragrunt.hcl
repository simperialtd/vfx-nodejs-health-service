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
    log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/prodca/providers/Microsoft.OperationalInsights/workspaces/prodca"
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
      "prodca" = {
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
  resource_group_name                    = dependency.rsg.outputs.resource_group["prodca"].name
  container_apps_environment_name_suffix = "prodca"
  infrastructure_subnet_id               = dependency.vnet.outputs.subnets["ca-infra"].id
  zone_redundancy_enabled                = true
  log_analytics_workspace_id             = dependency["log-analytics"].outputs.log_analytics_workspace_id
  private_endpoint_subnet_id             = dependency.vnet.outputs.subnets["ca"].id
  private_dns_zone_id                    = dependency.dns-zone.outputs.private_dns_zones["container_app"].id
  workload_profiles = [{
    name                  = "njs-health-prod"
    workload_profile_type = "D4"
    minimum_count         = 2
    maximum_count         = 3
  }]
  container_apps = [{
      name_suffix   = "nodejshs"
      container_registry_login_server = dependency.acr.outputs.container_registry.login_server
      image         = "${dependency.acr.outputs.container_registry.login_server}/nodejs-health-service"
      cpu           = 2
      memory        = "4Gi"
      min_replicas  = 2
      max_replicas  = 3
      target_port   = 8080
      workload_profile_name = "njs-health-prod"
      user_assigned_identity_id = dependency["user_assigned_identity"].outputs.user_assigned_identity["prodca"].id
      env = [
        {
          name  = "APP_ENVIRONMENT"
          value = "prod"
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
      http_scaling_rules = [{
        name                = "http-scaling-rule"
        type                = "http"
        concurrent_requests = 50
      }]
    }]
}





