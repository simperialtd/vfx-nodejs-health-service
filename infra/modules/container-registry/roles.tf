# Container Registry Repository Writer role for service principals (push/upload images)
resource "azurerm_role_assignment" "repository_writer" {
  for_each = toset(var.repository_writer_principal_ids)

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Container Registry Repository Writer"
  principal_id         = each.value
}

# Container Registry Repository Reader role for managed identities (pull/read images)
resource "azurerm_role_assignment" "repository_reader" {
  for_each = toset(var.repository_reader_principal_ids)

  scope                = azurerm_container_registry.this.id
  role_definition_name = "Container Registry Repository Reader"
  principal_id         = each.value
}
