output "vnet_id" {
  value       = azurerm_virtual_network.vnet.id
  description = "(Output) The virtual NetworkConfiguration ID."
}

output "subnet_ids" {
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
  description = "(Output) Map of the IDs of the subnets wrt their name."
}