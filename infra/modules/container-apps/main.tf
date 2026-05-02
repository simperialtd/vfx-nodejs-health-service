# Naming conventions from centralized module
module "cae_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "container_apps_environment"
}

module "ca_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "container_app"
}

module "pe_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "private_endpoint"
}

# Container Apps Environment
resource "azurerm_container_app_environment" "this" {
  name                                        = "${module.cae_naming.resource_name_prefix}-${var.container_apps_environment_name_suffix}"
  location                                    = var.location
  resource_group_name                         = var.resource_group_name
  infrastructure_resource_group_name          = "${var.resource_group_name}-infra"
  public_network_access                       = "Disabled"
  infrastructure_subnet_id                    = var.infrastructure_subnet_id #The Subnet must have a /21 or larger address space.
  internal_load_balancer_enabled              = true
  zone_redundancy_enabled                     = var.zone_redundancy_enabled
  logs_destination                            = var.log_analytics_workspace_id != null ? "log-analytics" : "azure-monitor"
  log_analytics_workspace_id                  = var.log_analytics_workspace_id
  mutual_tls_enabled                          = var.mutual_tls_enabled
  dapr_application_insights_connection_string = var.dapr_application_insights_connection_string

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  dynamic "workload_profile" {
    for_each = var.workload_profiles
    content {
      name                  = workload_profile.value.name
      workload_profile_type = workload_profile.value.workload_profile_type
      minimum_count         = workload_profile.value.minimum_count
      maximum_count         = workload_profile.value.maximum_count
    }
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "this" {
  name                = "${module.pe_naming.resource_name_prefix}-${azurerm_container_app_environment.this.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_container_app_environment.this.name}-psc"
    private_connection_resource_id = azurerm_container_app_environment.this.id
    is_manual_connection           = false
    subresource_names              = ["managedEnvironments"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

# Container Apps
resource "azurerm_container_app" "this" {
  for_each = { for app in var.container_apps : app.name_suffix => app }

  name                         = "${module.ca_naming.resource_name_prefix}${each.value.name_suffix}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = each.value.revision_mode
  workload_profile_name        = each.value.workload_profile_name
  max_inactive_revisions       = each.value.max_inactive_revisions


  registry {
    server   = each.value.container_registry_login_server
    identity = each.value.user_assigned_identity_id != null ? each.value.user_assigned_identity_id : "System"
  }

  identity {
    type         = each.value.user_assigned_identity_id != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = each.value.user_assigned_identity_id != null ? [each.value.user_assigned_identity_id] : []
  }

  ingress {
    external_enabled           = true
    target_port                = each.value.target_port
    transport                  = each.value.transport
    exposed_port               = each.value.exposed_port
    client_certificate_mode    = each.value.client_certificate_mode
    allow_insecure_connections = each.value.allow_insecure_connections

    dynamic "traffic_weight" {
      for_each = length(each.value.traffic_weights) > 0 ? each.value.traffic_weights : [{ percentage = 100, latest_revision = true, label = null, revision_suffix = null }]
      content {
        label           = traffic_weight.value.label
        latest_revision = traffic_weight.value.latest_revision
        revision_suffix = traffic_weight.value.revision_suffix
        percentage      = traffic_weight.value.percentage
      }
    }

    dynamic "cors" {
      for_each = each.value.cors != null ? [each.value.cors] : []
      content {
        allowed_origins           = cors.value.allowed_origins
        allow_credentials_enabled = cors.value.allow_credentials_enabled
        allowed_headers           = cors.value.allowed_headers
        allowed_methods           = cors.value.allowed_methods
        exposed_headers           = cors.value.exposed_headers
        max_age_in_seconds        = cors.value.max_age_in_seconds
      }
    }

    dynamic "ip_security_restriction" {
      for_each = each.value.ip_security_restrictions
      content {
        name             = ip_security_restriction.value.name
        action           = ip_security_restriction.value.action
        ip_address_range = ip_security_restriction.value.ip_address_range
        description      = ip_security_restriction.value.description
      }
    }
  }

  dynamic "dapr" {
    for_each = each.value.dapr != null ? [each.value.dapr] : []
    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  template {
    min_replicas                     = each.value.min_replicas
    max_replicas                     = each.value.max_replicas
    revision_suffix                  = each.value.revision_suffix
    termination_grace_period_seconds = each.value.termination_grace_period_seconds
    cooldown_period_in_seconds       = each.value.cooldown_period_in_seconds
    polling_interval_in_seconds      = each.value.polling_interval_in_seconds

    dynamic "volume" {
      for_each = each.value.volumes
      content {
        name          = volume.value.name
        storage_type  = volume.value.storage_type
        storage_name  = volume.value.storage_name
        mount_options = volume.value.mount_options
      }
    }

    container {
      name    = each.value.name_suffix
      image   = "${each.value.image}:${var.image_tag}"
      cpu     = each.value.cpu
      memory  = each.value.memory
      args    = each.value.args
      command = each.value.command

      dynamic "env" {
        for_each = each.value.env
        content {
          name        = env.value.name
          value       = env.value.secret_name == null ? env.value.value : null
          secret_name = env.value.secret_name
        }
      }

      dynamic "volume_mounts" {
        for_each = each.value.volume_mounts
        content {
          name     = volume_mounts.value.name
          path     = volume_mounts.value.path
          sub_path = volume_mounts.value.sub_path
        }
      }

      dynamic "liveness_probe" {
        for_each = each.value.liveness_probe != null ? [each.value.liveness_probe] : []
        content {
          transport               = liveness_probe.value.transport
          port                    = liveness_probe.value.port
          initial_delay           = liveness_probe.value.initial_delay
          interval_seconds        = liveness_probe.value.interval_seconds
          timeout                 = liveness_probe.value.timeout
          failure_count_threshold = liveness_probe.value.failure_count_threshold
          path                    = liveness_probe.value.path
          host                    = liveness_probe.value.host

          dynamic "header" {
            for_each = liveness_probe.value.headers
            content {
              name  = header.value.name
              value = header.value.value
            }
          }
        }
      }

      dynamic "readiness_probe" {
        for_each = each.value.readiness_probe != null ? [each.value.readiness_probe] : []
        content {
          transport               = readiness_probe.value.transport
          port                    = readiness_probe.value.port
          initial_delay           = readiness_probe.value.initial_delay
          interval_seconds        = readiness_probe.value.interval_seconds
          timeout                 = readiness_probe.value.timeout
          success_count_threshold = readiness_probe.value.success_count_threshold
          failure_count_threshold = readiness_probe.value.failure_count_threshold
          path                    = readiness_probe.value.path
          host                    = readiness_probe.value.host

          dynamic "header" {
            for_each = readiness_probe.value.headers
            content {
              name  = header.value.name
              value = header.value.value
            }
          }
        }
      }

      dynamic "startup_probe" {
        for_each = each.value.startup_probe != null ? [each.value.startup_probe] : []
        content {
          transport               = startup_probe.value.transport
          port                    = startup_probe.value.port
          initial_delay           = startup_probe.value.initial_delay
          interval_seconds        = startup_probe.value.interval_seconds
          timeout                 = startup_probe.value.timeout
          failure_count_threshold = startup_probe.value.failure_count_threshold
          path                    = startup_probe.value.path
          host                    = startup_probe.value.host

          dynamic "header" {
            for_each = startup_probe.value.headers
            content {
              name  = header.value.name
              value = header.value.value
            }
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = each.value.http_scaling_rules
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = http_scale_rule.value.authentication != null ? [http_scale_rule.value.authentication] : []
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = each.value.tcp_scaling_rules
      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication != null ? [tcp_scale_rule.value.authentication] : []
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = each.value.azure_queue_scaling_rules
      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = [azure_queue_scale_rule.value.authentication]
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = each.value.custom_scaling_rules
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.type
        metadata         = custom_scale_rule.value.metadata
        identity_id      = custom_scale_rule.value.identity_id

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication != null ? [custom_scale_rule.value.authentication] : []
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }
  }

  dynamic "secret" {
    for_each = each.value.secrets
    content {
      name                = secret.value.name
      value               = secret.value.value
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity
    }
  }
}


#Add custom domain certificates to Container Apps Environment
resource "azurerm_container_app_environment_certificate" "this" {
  for_each = merge([
    for container_app in var.container_apps : {
      for custom_domain in container_app.custom_domains :
      "${container_app.container_name_suffix}|${custom_domain.name}" => merge(custom_domain, { container_name_suffix = container_app.container_name_suffix })
    }
  ]...)

  name                         = each.value.name
  container_app_environment_id = azurerm_container_app_environment.this[each.value.container_name_suffix].id

  certificate_key_vault {
    identity            = azurerm_container_app_environment.this[each.value.container_name_suffix].identity[0].principal_id
    key_vault_secret_id = each.value.certificate_key_vault_secret_id
  }
}

#Configure custom domain
resource "azurerm_container_app_custom_domain" "this" {
  for_each = merge([
    for container_app in var.container_apps : {
      for custom_domain in container_app.custom_domains :
      "${container_app.container_name_suffix}|${custom_domain.name}" => merge(custom_domain, { container_name_suffix = container_app.container_name_suffix })
    }
  ]...)

  name                                     = each.value.fqdn
  container_app_id                         = azurerm_container_app.this[each.value.container_name_suffix].id
  container_app_environment_certificate_id = azurerm_container_app_environment_certificate.this[each.value.container_name_suffix].id
  certificate_binding_type                 = each.value.certificate_binding_type
}

