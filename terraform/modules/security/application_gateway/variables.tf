# variables.tf
variable "subnet_id" {
  type        = string
  description = "ID of the subnet for Application Gateway"
}

variable "public_ip_id" {
  type        = string
  description = "ID of the public IP for Application Gateway"
}

# variables.tf
variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location for resources"
}

variable "managed_identity_id" {
  type        = string
  description = "ID of the User Assigned Managed Identity for the Application Gateway"
}

variable "application_gateway" {
  type = object({
    name = string
    sku = object({
      name     = string
      tier     = string
      capacity = number
    })
    gateway_ip_configurations = map(object({
      subnet_id = string
    }))
    frontend_ip_configurations = map(object({
      name                 = string
      public_ip_address_id = string
    }))
    frontend_ports = map(object({
      name = string
      port = number
    }))
    ssl_certificates = map(object({
      name                = string
      key_vault_secret_id = string
    }))
    backend_address_pools = map(object({
      name  = string
      fqdns = list(string)
    }))
    backend_http_settings = map(object({
      name                  = string
      cookie_based_affinity = string
      path                 = string
      port                 = number
      protocol            = string
      request_timeout     = number
      probe_name         = string
    }))
    http_listeners = map(object({
      name                           = string
      frontend_ip_configuration_name = string
      frontend_port_name            = string
      protocol                      = string
      ssl_certificate_name          = optional(string)
      host_name                     = optional(string)
    }))
    probes = map(object({
      name                = string
      host               = string
      interval           = number
      path               = string
      timeout            = number
      unhealthy_threshold = number
      protocol           = string
      port               = number
      match = object({
        status_codes = list(string)
      })
    }))
    request_routing_rules = map(object({
      name                       = string
      rule_type                 = string
      http_listener_name        = string
      backend_address_pool_name = string
      backend_http_settings_name = string
      priority                  = number
    }))
    waf_configuration = object({
      enabled                  = bool
      firewall_mode           = string
      rule_set_type          = string
      rule_set_version       = string
      file_upload_limit_mb   = number
      request_body_check     = bool
      max_request_body_size_kb = number
      disabled_rule_groups = list(object({
        rule_group_name = string
        rules          = list(string)
      }))
      exclusions = list(object({
        match_variable          = string
        selector               = string
        selector_match_operator = string
      }))
    })
    ssl_policy = object({
      policy_type = string
      policy_name = string
    })
    private_link_configuration = object({
      enabled = bool
    })
    tags = map(string)
  })
  description = "Application Gateway configuration"
}

# variable "diagnostics" {
#   type = object({
#     log_analytics_workspace_id = string
#     metrics = list(string)
#     logs    = list(string)
#     retention_policy = object({
#       enabled = bool
#       days    = number
#     })
#   })
#   description = "Diagnostics settings for Application Gateway"
# }

variable "tags" {
  type        = map(string)
  description = "Tags to be applied to resources"
  default     = {}
}
