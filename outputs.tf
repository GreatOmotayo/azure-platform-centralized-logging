# outputs.tf
output "workspace_id" {
  description = "Full resource ID — used by consuming projects for diagnostic settings"
  value       = azurerm_log_analytics_workspace.shared.id
}

output "workspace_customer_id" {
  description = "Workspace (customer) ID — used when App Insights or agents need the GUID, not the resource ID"
  value       = azurerm_log_analytics_workspace.shared.workspace_id
}

output "workspace_name" {
  value = azurerm_log_analytics_workspace.shared.name
}

output "resource_group_name" {
  value = azurerm_resource_group.logging_foundation.name
}