resource "azurerm_virtual_network" "vnet" {
  address_space       = var.vnet_address_space
  location            = var.vnet_location
  name                = "${var.prefix}-${var.vnet_name}"
  resource_group_name = var.resource_group_name
  bgp_community       = var.bgp_community
  dns_servers         = var.dns_servers
  tags                = merge(var.tags, var.common_tags)


  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan != null ? [var.ddos_protection_plan] : []

    content {
      enable = ddos_protection_plan.value.enable
      id     = ddos_protection_plan.value.id
    }
  }
}

resource "azurerm_subnet" "subnet" {
  depends_on = [azurerm_virtual_network.vnet]
  for_each   = { for subnet in var.subnets_config : subnet.subnet_name => subnet }

  address_prefixes                  = each.value.address_prefix
  name                              = each.key
  default_outbound_access_enabled   = each.value.default_outbound_access_enabled
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
  service_endpoints                 = lookup(each.value, "service_endpoints", null)

  dynamic "delegation" {
    for_each = each.value.delegation != null ? each.value.delegation : {}
    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.service_actions
      }
    }
  }

}

resource "azurerm_network_security_group" "nsg" {
  for_each = var.nsgs

  name                = each.key
  location            = var.vnet_location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = each.value.security_rules

    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags

}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  depends_on = [azurerm_virtual_network.vnet, azurerm_network_security_group.nsg]
  for_each   = { for subnet in var.subnets_config : subnet.subnet_name => subnet if subnet.nsg_to_be_associated != null }

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_to_be_associated].id
}
