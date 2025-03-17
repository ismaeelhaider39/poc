locals {
  georeplications = {
    for georeplication in var.georeplications : georeplication.location => georeplication
  }

  diagnostic_setting_metric_categories = ["AllMetrics"]
}

resource "azurerm_container_registry" "acr" {
  name                          = replace("${var.prefix}-${var.registry_name}", "-", "")

  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  admin_enabled                 = var.admin_enabled
  public_network_access_enabled = var.public_network_access_enabled
  network_rule_bypass_option    = var.network_rule_bypass_azure_services ? "AzureServices" : "None"

  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" ? [0] : []

    content {
      default_action = var.network_rule_set_default_action

      ip_rule = [
        for ip_range in var.network_rule_set_ip_rules : {
          action   = "Allow" # Only supported value
          ip_range = ip_range
        }
      ]
    }
  }

  dynamic "georeplications" {
    for_each = local.georeplications

    content {
      location                = georeplications.value["location"]
      zone_redundancy_enabled = georeplications.value["zone_redundancy_enabled"]
    }
  }

  tags                = merge(var.tags , var.common_tags)

  lifecycle {
    precondition {
      condition     = var.sku == "Premium" ? length(var.georeplications) >= 0 : length(var.georeplications) == 0
      error_message = "Geo-replications can only be configured if SKU is \"Premium\"."
    }
    ignore_changes = [ tags ]
  }
}
