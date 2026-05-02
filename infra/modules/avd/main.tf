
# Naming conventions from centralized module
module "host_pool_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "avd_host_pool"
}

module "desktop_workspace_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "avd_desktop_workspace"
}

module "desktop_application_group_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "avd_desktop_application_group"
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  resource_group_name      = var.resource_group_name
  name                     = "${module.host_pool_naming.resource_name_prefix}-${var.avd_host_pool_suffix}"
  description              = var.avd_host_pool_description
  custom_rdp_properties    = var.custom_rdp_properties
  load_balancer_type       = var.load_balancer_type
  maximum_sessions_allowed = var.maximum_sessions_allowed
  location                 = var.location
  preferred_app_group_type = var.preferred_app_group_type
  public_network_access    = var.avd_host_pool_public_network_access
  start_vm_on_connect      = var.start_vm_on_connect
  type                     = var.avd_host_pool_type
  validate_environment     = var.validate_environment
}

resource "azurerm_virtual_desktop_workspace" "this" {
  resource_group_name           = var.resource_group_name
  name                          = "${module.desktop_workspace_naming.resource_name_prefix}-${var.workspace_suffix}"
  location                      = var.location
  public_network_access_enabled = var.workspace_public_network_access
}

resource "azurerm_virtual_desktop_application_group" "this" {
  for_each = { for dag in var.application_groups : dag.suffix => dag }

  resource_group_name          = var.resource_group_name
  name                         = "${module.desktop_application_group_naming.resource_name_prefix}-${each.value.suffix}"
  location                     = var.location
  type                         = "Desktop"
  default_desktop_display_name = each.value.default_desktop_display_name
  description                  = each.value.description
  friendly_name                = each.value.friendly_name
  host_pool_id                 = azurerm_virtual_desktop_host_pool.this.id
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  for_each = { for dag in var.application_groups : dag.suffix => dag }

  application_group_id = azurerm_virtual_desktop_application_group.this[each.value.suffix].id
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
}