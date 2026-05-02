output "user_assigned_identity" {
  description = "User-assigned identity details (id, name, principal_id, and client_id)"
  value = {
    for suffix in toset(var.identity_suffixes) : suffix => {
      id           = azurerm_user_assigned_identity.this[suffix].id
      name         = azurerm_user_assigned_identity.this[suffix].name
      principal_id = azurerm_user_assigned_identity.this[suffix].principal_id
      client_id    = azurerm_user_assigned_identity.this[suffix].client_id
    }
  }
}
