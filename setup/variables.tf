variable "location" {
  description = "The Azure region where the Resource Group will be created"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the Azure Resource Group"
  type        = string
  default     = "test-resource-group"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "IT-Team"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "poc-azure"
  
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters."
  }
}

variable "vnet_configurations" {
  description = "List of Map of vnets along with their subnets configuration (subnet name, address prefix, nsgs, route tables and associations)"
  type = object({
    vnet_name          = string
    vnet_address_space = list(string)
    vnet_location      = optional(string, null)
    subnets_config = list(object({
      subnet_name                       = string
      address_prefix                    = list(string)
      service_endpoints                 = optional(set(string), [])
      nsg_to_be_associated              = optional(string, null)
      rt_to_be_associated               = optional(string, null)
      associate_nat_gateway             = optional(bool, false)
      default_outbound_access_enabled   = optional(bool, false)
      private_endpoint_network_policies = optional(any, "Disabled")
      delegation = optional(map(object({
        service_name    = string
        service_actions = list(string)
      })))
    }))
    nsgs = map(object({
      security_rules = optional(list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      })), [])
    }))
    tags               = optional(map(string),null)
  })
}

# variable "uamis" {
#   description = "A map of UAMI configurations."
#   type = map(object({
#     name              = string
#     tags              = map(string)
#     role_assignment   = object({
#       scope          = string
#       role           = string
#     })
#   }))
# }

variable "aks_cluster_config" {
  description = "Configuration map for AKS cluster"
  type = object({
    cluster_subnet_name         = optional(string)
    cluster_name                = optional(string)
    resource_group_name         = optional(string)
    identity_ids                = optional(list(string))
    kubernetes_version          = optional(string)
    automatic_channel_upgrade   = optional(string)
    agents_availability_zones   = optional(list(string))
    temporary_name_for_rotation = optional(string)
    oidc_issuer_enabled         = optional(bool)
    workload_identity_enabled   = optional(bool)
    agents_count                = optional(number)
    agents_size                 = optional(string)
    agents_max_count            = optional(number)
    agents_max_pods             = optional(number)
    agents_min_count            = optional(number)
    agents_pool_name            = optional(string)
    node_pools = optional(map(object({
      name                = string
      vm_size             = string
      vnet_subnet_id      = optional(string)
      os_type             = string
      max_pods            = optional(number)
      enable_auto_scaling = optional(bool)
      node_labels         = optional(map(string))
      node_taints         = optional(list(string))
      os_disk_size_gb     = optional(number)
      max_count           = optional(number)
      min_count           = optional(number)
      node_count          = number
      zones               = optional(list(string))

    })))
    attached_acr_id_map = optional(map(string))
    agents_pool_linux_os_configs = optional(list(object({
      transparent_huge_page_enabled = string
      sysctl_configs = list(object({
        fs_aio_max_nr               = number
        fs_file_max                 = number
        fs_inotify_max_user_watches = number
      }))
    })))
    agents_type                         = optional(string)
    azure_policy_enabled                = optional(bool)
    enable_auto_scaling                 = optional(bool)
    enable_host_encryption              = optional(bool)
    ingress_application_gateway_enabled = optional(bool)
    application_gateway_for_ingress = optional(object({
      name        = string
      subnet_cidr = string
    }))
    create_role_assignments_for_application_gateway = optional(bool)
    local_account_disabled                          = optional(bool)
    log_analytics_workspace_enabled                 = optional(bool)
    net_profile_dns_service_ip                      = optional(string)
    net_profile_service_cidr                        = optional(string)
    network_plugin                                  = optional(string)
    network_policy                                  = optional(string)
    os_disk_size_gb                                 = optional(number)
    private_cluster_enabled                         = optional(bool)
    rbac_aad                                        = optional(bool)
    rbac_aad_managed                                = optional(bool)
    role_based_access_control_enabled               = optional(bool)
    key_vault_secrets_provider_enabled              = optional(bool)
    rbac_aad_admin_group_object_ids                 = optional(list(string))
    kms_enabled                                     = optional(bool)
    kms_key_vault_key_id                            = optional(string)
    identity_type                                   = optional(string)
    sku_tier                                        = optional(string)
    vnet_subnet_id                                  = optional(string)
    # tags                                            = optional(map(string))
  })
}


# variable "common_tags" {
#   type        = map(string)
#   description = "Common tags to be applied to resources"
#   default = {
#     "Owner"       = "Admin"
#     "Project"     = "DummyProject"
#   }
# }
