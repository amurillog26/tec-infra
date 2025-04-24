# variables.tf
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location for resources"
}

variable "apim" {
  type = object({
    name                = string
    publisher_name      = string
    publisher_email     = string
    sku_name           = string
    capacity           = number
    subnet_id          = string
    virtual_network_type = string
    # Opcional: Puedes añadir explícitamente el ID de IP pública si es necesario
    public_ip_address_id = optional(string)
    protocols = object({
      enable_http2 = bool
    })
    security = object({
      enable_backend_ssl30  = bool
      enable_backend_tls10  = bool
      enable_backend_tls11  = bool
      enable_frontend_ssl30 = bool
      enable_frontend_tls10 = bool
      enable_frontend_tls11 = bool
    })
    identity_type = string
    policy = optional(object({
      xml_content = string
    }))
    products = map(object({
      product_id            = string
      display_name         = string
      description         = string
      subscription_required = bool
      approval_required    = bool
      published           = bool
      subscriptions_limit = number
    }))
    apis = map(object({
      name         = string
      display_name = string
      path         = string
      protocols    = list(string)
      revision     = string
      version      = optional(string)
      version_set  = optional(object({
        name = string
        versioning_scheme = string
      }))
    }))
    named_values = map(object({
      display_name = string
      value        = string
    }))
    additional_settings = object({
      enable_sign_in = bool
      enable_sign_up = bool
    })
    tags = map(string)
  })
  description = "API Management configuration"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}

variable "tenant_id" {
  type        = string
  description = "ID del tenant de Azure"
}
