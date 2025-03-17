variable "registry_name" {
  description = "(Required) The name of this Container Registry."
}

variable "location" {
  description = "(Required) The supported Azure location where the resources exist."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the resources."
  type        = string
}

variable "sku" {
  description = "(Optional) The SKU tier for the Container Registry."
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "(Optional) Is admin enabled for this Container Registry?"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "(Optional) Should public network access be enabled for this Container Registry?"
  type        = bool
  default     = true
}

variable "network_rule_bypass_azure_services" {
  description = "(Optional) Should Azure services be allowd to bypass the network rules for this Container Registry? Only applicable when SKU is Premium."
  type        = bool
  default     = true
}

variable "network_rule_set_default_action" {
  description = "(Optional) The default action of the network rule set for this Container Registry. Only applicable when SKU is Premium."
  type        = string
  default     = "Deny"
}

variable "network_rule_set_ip_rules" {
  description = "(Optional) The public IPs or IP ranges in CIDR format that should be able to access this Container Registry. Only applicable when SKU is Premium."
  type        = list(string)
  default     = []
}

variable "georeplications" {
  description = "(Optional) A list of properties of the geo-replication blocks for this Container Registry. Only availiable for Premium SKU."

  type = list(object({
    location                = string  
    zone_redundancy_enabled = optional(bool, false)
  }))

  default = []

  validation {
    condition     = length(var.georeplications) == length(distinct([for georeplication in var.georeplications : georeplication.location]))
    error_message = "Value of property \"location\" must be unique for each object."
  }
}

variable "tags" {
  type        = map(string)
  description = "(Optional) A map of tags to apply to resources"
  default = {}
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to resources"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix/Identifier for Container Registry Resource."
}