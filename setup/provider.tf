provider "azurerm" {
  features {}

subscription_id="3b0f549f-0e89-4e6b-b010-0781de4d03e8"
}

provider "azapi" {
}
  
provider "kubernetes" {
  host                   = module.aks.kube_config.host
  client_certificate     = base64decode(module.aks.kube_config.client_certificate)
  client_key             = base64decode(module.aks.kube_config.client_key)
  cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.aks.kube_config.host
    client_certificate     = base64decode(module.aks.kube_config.client_certificate)
    client_key             = base64decode(module.aks.kube_config.client_key)
    cluster_ca_certificate = base64decode(module.aks.kube_config.cluster_ca_certificate)
  }
}


# terraform {

#   required_version = ">= 1.3.0"

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = ">= 3.0.0"
#     }
#     azapi = {
#       source  = "azure/azapi"
#       version = ">= 1.4.0, < 2.0.0"
#     }
#   }
# }

# provider "azurerm" {
#   features {}
# }

# provider "azapi" {}
