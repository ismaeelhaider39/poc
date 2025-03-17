data "azurerm_resource_group" "data_rg" {
    name = var.resource_group_name
}

# resource "azurerm_role_assignment" "application_gateway_byo_vnet_network_contributor" {
#   count = var.create_role_assignments_for_application_gateway && local.ingress_application_gateway_enabled ? 1 : 0

#   principal_id         = azurerm_kubernetes_cluster.main.ingress_application_gateway[0].ingress_application_gateway_identity[0].object_id
#   scope                = join("/", slice(local.default_nodepool_subnet_segments, 0, length(local.default_nodepool_subnet_segments) - 2))
#   role_definition_name = "Network Contributor"

#   lifecycle {
#     precondition {
#       condition     = var.application_gateway_for_ingress == null || !(var.create_role_assignments_for_application_gateway && var.vnet_subnet_id == null)
#       error_message = "When `var.vnet_subnet_id` is `null`, you must set `var.create_role_assignments_for_application_gateway` to `false`, set `var.application_gateway_for_ingress` to `null`."
#     }
#   }
# }

resource "azurerm_role_assignment" "acr" {

  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  scope                            = var.acr_id
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
}


resource "azurerm_role_assignment" "network_contributor_on_subnet" {
#   for_each = var.network_contributor_role_assigned_subnet_ids

  principal_id         = coalesce(azurerm_kubernetes_cluster.main.identity[0].principal_id, var.client_id)
  scope                = data.azurerm_resource_group.data_rg.id
  role_definition_name = "Network Contributor"

  lifecycle {
    precondition {
      condition     = !var.create_role_assignment_network_contributor
      error_message = "Cannot set both of `var.create_role_assignment_network_contributor` and `var.network_contributor_role_assigned_subnet_ids`."
    }
  }
}