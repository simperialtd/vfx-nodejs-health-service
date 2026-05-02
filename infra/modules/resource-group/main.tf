# Naming conventions from centralized module
module "naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "resource_group"
}

resource "azurerm_resource_group" "this" {
  for_each = toset(var.resource_groups_suffixes)

  name     = "${module.naming.resource_name_prefix}-${each.value}"
  location = var.location
}
