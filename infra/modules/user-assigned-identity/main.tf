# Naming conventions from centralized module
module "naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "user_assigned_identity"
}

resource "azurerm_user_assigned_identity" "this" {
  for_each = toset(var.identity_suffixes)

  name                = "${module.naming.resource_name_prefix}-${each.value}"
  location            = var.location
  resource_group_name = var.resource_group_name
}
