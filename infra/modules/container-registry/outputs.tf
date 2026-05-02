output "container_registry" {
  description = "Container registry details (id, name, and login_server)"
  value = {
    id           = azurerm_container_registry.this.id
    name         = azurerm_container_registry.this.name
    login_server = azurerm_container_registry.this.login_server
  }
}
