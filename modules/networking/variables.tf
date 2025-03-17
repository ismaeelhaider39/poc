variable "resource_group_name" {
  type        = string
  description = "(Required) Name of the resource group to be created."
  nullable    = false
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix to be added."
}

variable "vnet_name" {
  type        = string
  description = "(Required) Name of the vnet to create."
}

variable "vnet_location" {
  type        = string
  description = "(Required) The location of the vnet to create."
  nullable    = false
}

variable "vnet_address_space" {
  type        = list(string)
  description = "(Optional) The address space that is used by the virtual network."
}


variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "(Optional) The DNS servers to be used with vNet."
}

variable "ddos_protection_plan" {
  type = object({
    enable = bool
    id     = string
  })
  default     = null
  description = "(Optional) The set of DDoS protection plan configuration."
}

variable "bgp_community" {
  type        = string
  default     = null
  description = "(Optional) The BGP community attribute in format `<as-number>:<community-value>`."
}

variable "subnets_config" {
  description = "(Required) List of Subnet configurations within a VNet containing name, address prefix, outbound access, service endpoints, nsg, rt and nat association."
  type = list(object({
    subnet_name                       = string
    address_prefix                    = list(string)
    default_outbound_access_enabled   = optional(bool, false)
    service_endpoints                 = optional(set(string), [])
    nsg_to_be_associated              = optional(string, null)
    rt_to_be_associated               = optional(string, null)
    associate_nat_gateway             = optional(bool, false)
    private_endpoint_network_policies = optional(any, "Disabled")
    delegation = optional(map(object({
      service_name    = string
      service_actions = list(string)
    })))
  }))
  nullable = false
}

variable "nsgs" {
  description = "(Optional) Map of Network Security Groups (NSGs), each defined by its associated security rules."
  type = map(object({
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
}

variable "tags" {
  type        = map(string)
  nullable = true
  description = "(Optional) A map of tags to apply to resources."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to resources"
  default = {
  }
}