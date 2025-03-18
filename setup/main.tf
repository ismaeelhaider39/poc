locals {
  env = terraform.workspace

  name_prefix = replace("${var.project_name}-${local.env}", "/[^a-zA-Z0-9-]/", "")

  common_tags = {
    Environment       = local.env
    ManagedBy         = "Terraform"
    Project           = var.project_name
    Owner             = var.owner
    CreationTimestamp = formatdate("YYYY-MM-DD", timestamp())
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}-rg-${local.env}"
  location = var.location
}

module "vnet" {
  source              = "../modules/networking"
  resource_group_name = azurerm_resource_group.rg.name
  prefix              = local.name_prefix
  vnet_name           = "${var.vnet_configurations.vnet_name}-${local.env}"
  vnet_address_space  = var.vnet_configurations.vnet_address_space
  vnet_location       = var.vnet_configurations.vnet_location != null ? var.vnet_configurations.vnet_location : azurerm_resource_group.rg.location
  
  subnets_config      = var.vnet_configurations.subnets_config
  nsgs                = var.vnet_configurations.nsgs
  tags                = var.vnet_configurations.tags
  common_tags         = local.common_tags

}


# module "uami_role" {
#   source = "../modules/uami_role_module"

#   for_each = var.uamis
#   uami_name           = each.value.name
#   prefix = local.env
#   resource_group_name = azurerm_resource_group.rg.name
#   location           = var.location
#   role_assignment = {
#     scope        = each.value.role_assignment.scope
#     role         = each.value.role_assignment.role
#   }
#   tags                = merge(var.common_tags, each.value.tags)
# }

# output "uami_role_ids" {
#   value = module.uami_role["uami1"].managed_identity_id
# }


# output "vnets" {
#   value = module.vnet["test-vnet"].subnet_ids["test-subnet1"]
# }

module "acr" {
  # count               = var.create_acr ? 1 : 0
  source              = "../modules/acr"
  prefix              = local.name_prefix
  registry_name       = "acr1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  # tags                = local.common_tags
  common_tags         = local.common_tags
}

module "aks" {
  source              = "../modules/aks"
  resource_group_name         = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  cluster_name                = "${var.aks_cluster_config.cluster_name}-${local.env}"
  kubernetes_version = var.aks_cluster_config.kubernetes_version
  prefix = local.name_prefix  #"${each.value.cluster_name}-${local.env}"
  azure_policy_enabled                            = var.aks_cluster_config.azure_policy_enabled
  enable_auto_scaling                             = var.aks_cluster_config.enable_auto_scaling
  enable_host_encryption                          = var.aks_cluster_config.enable_host_encryption
  ingress_application_gateway_enabled             = var.aks_cluster_config.ingress_application_gateway_enabled
  role_based_access_control_enabled               = var.aks_cluster_config.role_based_access_control_enabled
  acr_id  = module.acr.acr_id
  # identity_ids = [for id in  each.value.identity_ids:  module.uami_role[id].managed_identity_id if length(module.uami_role["uami1"].managed_identity_id) > 0 ] 
  common_tags = local.common_tags 

  providers = {
    azapi = azapi
  }
  depends_on = [ azurerm_resource_group.rg ]
}




resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  
  set {
    name  = "crds.install"
    value = "true"
  }
  values = [
    <<-EOT
    server:
      extraArgs:
        - --insecure
      service:
        type: LoadBalancer
    EOT
  ]
}

# Resource to check if the Application CRD is ready
# resource "null_resource" "wait_for_argocd_crd" {
#   depends_on = [helm_release.argocd]

#   provisioner "local-exec" {
#     command = <<EOT
#       until kubectl get crd applications.argoproj.io >/dev/null 2>&1; do
#         echo "Waiting for ArgoCD CRD to be available..."
#         sleep 10
#       done
#       echo "ArgoCD CRD is available."
#     EOT
#   }
# }

# ArgoCD Application manifest
resource "kubernetes_manifest" "argocd_application" {
  depends_on = [
    helm_release.argocd,
    # null_resource.wait_for_argocd_crd,  # Add dependency on CRD readiness
  ]
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "nginx-application"
      namespace = "argocd"
      annotations = {
        "argocd-image-updater.argoproj.io/image-list" = "nginx=nginx"
        "argocd-image-updater.argoproj.io/nginx.update-strategy" = "semver"
        "argocd-image-updater.argoproj.io/nginx.allow-tags" = "regex:^[0-9]+\\.[0-9]+\\.[0-9]+$"
        "argocd-image-updater.argoproj.io/write-back-method" = "git"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/ismaeelhaider39/poc.git"  # Replace with your Git repo URL
        targetRevision = "HEAD"  # Replace with your branch/tag
        path           = "app"  # Path to your chart in the repo
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "nginx"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}