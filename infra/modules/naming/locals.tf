locals {
  # Environment short name mapping
  env_short_map = {
    sbx     = "s"
    dev     = "d"
    test    = "t"
    preprod = "a"
    prod    = "p"
    hub     = "h"
  }

  # Location short name mapping
  location_short_map = {
    westeurope = "weu"
    eastus     = "eus"
    uksouth    = "uks"
  }

  resource_type_short_map = {
    resource_group                = "rsg"
    virtual_network               = "vnet"
    subnet                        = "snet"
    network_security_group        = "nsg"
    network-interface             = "nic"
    public_ip                     = "pip"
    virtual_machine               = "vm"
    route_table                   = "rt"
    avd_host_pool                 = "vdpool"
    avd_desktop_workspace         = "vdws"
    avd_desktop_application_group = "vdag"
    container_registry            = "cr"
    container_apps_environment    = "cae"
    container_app                 = "ca"
    osdisk                        = "osdisk"
    log_analytics_workspace       = "law"
    user_assigned_identity        = "uai"
    private_endpoint              = "pe"
    key_vault                     = "kv"
    private_endpoint              = "pe"
  }

  # Compute shortcodes
  env_short_code           = lookup(local.env_short_map, var.environment)
  location_short_code      = lookup(local.location_short_map, var.location)
  resource_type_short_code = lookup(local.resource_type_short_map, var.resource_type)

}
