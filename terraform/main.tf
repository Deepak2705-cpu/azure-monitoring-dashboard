terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "deepaktfstatestorage"
    container_name       = "tfstate"
    key                  = "monitoring.tfstate"
  }
}

provider "azurerm" {
  features {}
}

# -----------------------------------------------
# Resource Group
# -----------------------------------------------
resource "azurerm_resource_group" "monitoring" {
  name     = "deepak-monitoring-rg"
  location = var.location

  tags = {
    project    = "azure-monitoring-dashboard"
    managed_by = "Terraform"
    owner      = "Deepak TR"
  }
}

# -----------------------------------------------
# Log Analytics Workspace
# -----------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = "deepak-log-analytics"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    managed_by = "Terraform"
  }
}

# -----------------------------------------------
# Application Insights
# -----------------------------------------------
resource "azurerm_application_insights" "main" {
  name                = "deepak-app-insights"
  location            = azurerm_resource_group.monitoring.location
  resource_group_name = azurerm_resource_group.monitoring.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  tags = {
    managed_by = "Terraform"
  }
}

# -----------------------------------------------
# Action Group — Email + Webhook Alerts
# -----------------------------------------------
resource "azurerm_monitor_action_group" "critical" {
  name                = "deepak-critical-alerts"
  resource_group_name = azurerm_resource_group.monitoring.name
  short_name          = "critical"

  email_receiver {
    name          = "Deepak TR"
    email_address = "deepuraj0527@gmail.com"
  }

  webhook_receiver {
    name        = "teams-webhook"
    service_uri = var.teams_webhook_url
  }
}

# -----------------------------------------------
# Metric Alert — High CPU on VM
# -----------------------------------------------
resource "azurerm_monitor_metric_alert" "high_cpu" {
  name                = "alert-high-cpu"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.vm_resource_id]
  description         = "Triggers when VM CPU exceeds 85% for 5 minutes"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}

# -----------------------------------------------
# Metric Alert — High Memory
# -----------------------------------------------
resource "azurerm_monitor_metric_alert" "high_memory" {
  name                = "alert-high-memory"
  resource_group_name = azurerm_resource_group.monitoring.name
  scopes              = [var.vm_resource_id]
  description         = "Triggers when available memory drops below 500MB"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Available Memory Bytes"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 524288000
  }

  action {
    action_group_id = azurerm_monitor_action_group.critical.id
  }
}
