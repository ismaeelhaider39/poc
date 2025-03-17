output "vnets" {
  value = module.vnet.vnet_id
}

output "acr_id" {
  value = module.acr.acr_id
}

output "kube_config" {
  value = module.aks.kube_config
  sensitive = true
}