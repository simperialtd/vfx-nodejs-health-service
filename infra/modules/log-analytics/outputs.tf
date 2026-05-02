output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace Name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_shared_key" {
  description = "Log Analytics Workspace Shared Key"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

