output "container_app_environment" {
  description = "Container Apps Environment details (id, name, and default_domain)"
  value = {
    id             = azurerm_container_app_environment.this.id
    name           = azurerm_container_app_environment.this.name
    default_domain = azurerm_container_app_environment.this.default_domain
  }
}

output "container_apps" {
  description = "Container Apps details (id, name, and latest_revision_fqdn)"
  value = {
    for key, app in azurerm_container_app.this : key => {
      id                   = app.id
      name                 = app.name
      latest_revision_fqdn = app.latest_revision_fqdn
    }
  }
}
