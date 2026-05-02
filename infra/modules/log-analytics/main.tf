# Naming conventions from centralized module
module "naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "log_analytics_workspace"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                         = "${module.naming.resource_name_prefix}-${var.log_analytics_workspace_suffix}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  sku                          = var.sku
  retention_in_days            = var.retention_in_days
  daily_quota_gb               = var.daily_quota_gb
  internet_ingestion_enabled   = var.internet_ingestion_enabled
  internet_query_enabled       = var.internet_query_enabled
  local_authentication_enabled = var.local_authentication_enabled
  cmk_for_query_forced         = var.cmk_for_query_forced
}
