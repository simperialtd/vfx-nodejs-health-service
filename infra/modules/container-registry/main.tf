# Naming conventions from centralized module
module "acr_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "container_registry"
}

# Naming for private endpoint
module "pe_naming" {
  source = "../naming"

  environment   = var.environment
  location      = var.location
  resource_type = "private_endpoint"
}

resource "azurerm_container_registry" "this" {
  name                          = replace("${module.acr_naming.resource_name_prefix}${var.acr_name_suffix}", "-", "")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  zone_redundancy_enabled       = var.zone_redundancy_enabled
  retention_policy_in_days      = var.sku == "Premium" ? var.retention_policy_days : null
  data_endpoint_enabled         = var.sku == "Premium" ? true : false

  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
    }
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "this" {
  name                = "${module.pe_naming.resource_name_prefix}-${azurerm_container_registry.this.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${azurerm_container_registry.this.name}-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
