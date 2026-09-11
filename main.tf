resource "azurerm_resource_group" "logging_foundation" {
  name     = "rg-platform-logging"
  location = var.location

  tags = var.environment_tag
}

resource "azurerm_log_analytics_workspace" "shared" {
  name                = "law-platform-shared"
  resource_group_name = azurerm_resource_group.logging_foundation.name
  location            = azurerm_resource_group.logging_foundation.location
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  daily_quota_gb      = var.daily_quota_gb

  tags = var.environment_tag
}