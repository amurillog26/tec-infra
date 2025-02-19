locals {
  appgw_config = {
    name = var.application_gateway.name
    sku  = var.application_gateway.sku

    gateway_ip_configurations = {
      main = {
        subnet_id = var.subnet_id  # Pasado como variable separada
      }
    }

    frontend_ip_configurations = {
      public = {
        name                 = var.application_gateway.frontend_ip_configurations.public.name
        public_ip_address_id = var.public_ip_id  # Pasado como variable separada
      }
    }

    frontend_ports     = var.application_gateway.frontend_ports
    ssl_certificates   = var.application_gateway.ssl_certificates
    backend_address_pools = var.application_gateway.backend_address_pools
    backend_http_settings = var.application_gateway.backend_http_settings
    http_listeners    = var.application_gateway.http_listeners
    probes           = var.application_gateway.probes
    request_routing_rules = var.application_gateway.request_routing_rules
    waf_configuration = var.application_gateway.waf_configuration
    ssl_policy       = var.application_gateway.ssl_policy
    private_link_configuration = var.application_gateway.private_link_configuration
    tags            = var.application_gateway.tags
  }
}

resource "azurerm_application_gateway" "agw" {
  name                = local.appgw_config.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = local.appgw_config.sku.name
    tier     = local.appgw_config.sku.tier
    capacity = local.appgw_config.sku.capacity
  }

  gateway_ip_configuration {
    name      = "main"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = local.appgw_config.frontend_ip_configurations.public.name
    public_ip_address_id = var.public_ip_id
  }

  dynamic "frontend_port" {
    for_each = local.appgw_config.frontend_ports
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.application_gateway.ssl_certificates
    content {
      name                = ssl_certificate.value.name
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.application_gateway.backend_address_pools
    content {
      name  = backend_address_pool.value.name
      fqdns = backend_address_pool.value.fqdns
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.application_gateway.backend_http_settings
    content {
      name                  = backend_http_settings.value.name
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      path                 = backend_http_settings.value.path
      port                 = backend_http_settings.value.port
      protocol            = backend_http_settings.value.protocol
      request_timeout     = backend_http_settings.value.request_timeout
      probe_name         = backend_http_settings.value.probe_name
    }
  }

  dynamic "http_listener" {
    for_each = var.application_gateway.http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name            = http_listener.value.frontend_port_name
      protocol                      = http_listener.value.protocol
      ssl_certificate_name          = lookup(http_listener.value, "ssl_certificate_name", null)
      host_name                     = lookup(http_listener.value, "host_name", null)
    }
  }

  dynamic "probe" {
    for_each = var.application_gateway.probes
    content {
      name                = probe.value.name
      host               = probe.value.host
      interval           = probe.value.interval
      path               = probe.value.path
      timeout            = probe.value.timeout
      unhealthy_threshold = probe.value.unhealthy_threshold
      protocol           = probe.value.protocol
      port               = probe.value.port

      dynamic "match" {
        for_each = probe.value.match != null ? [probe.value.match] : []
        content {
          status_code = match.value.status_codes
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.application_gateway.request_routing_rules
    content {
      name                       = request_routing_rule.value.name
      rule_type                 = request_routing_rule.value.rule_type
      http_listener_name        = request_routing_rule.value.http_listener_name
      backend_address_pool_name = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      priority                  = request_routing_rule.value.priority
    }
  }

  waf_configuration {
    enabled                  = var.application_gateway.waf_configuration.enabled
    firewall_mode           = var.application_gateway.waf_configuration.firewall_mode
    rule_set_type          = var.application_gateway.waf_configuration.rule_set_type
    rule_set_version       = var.application_gateway.waf_configuration.rule_set_version
    file_upload_limit_mb   = var.application_gateway.waf_configuration.file_upload_limit_mb
    request_body_check     = var.application_gateway.waf_configuration.request_body_check
    max_request_body_size_kb = var.application_gateway.waf_configuration.max_request_body_size_kb

    dynamic "disabled_rule_group" {
      for_each = var.application_gateway.waf_configuration.disabled_rule_groups
      content {
        rule_group_name = disabled_rule_group.value.rule_group_name
        rules          = disabled_rule_group.value.rules
      }
    }

    dynamic "exclusion" {
      for_each = var.application_gateway.waf_configuration.exclusions
      content {
        match_variable          = exclusion.value.match_variable
        selector               = exclusion.value.selector
        selector_match_operator = exclusion.value.selector_match_operator
      }
    }
  }

  ssl_policy {
    policy_type = var.application_gateway.ssl_policy.policy_type
    policy_name = var.application_gateway.ssl_policy.policy_name
  }

  tags = merge(var.tags, var.application_gateway.tags)

  identity {
    type = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }
}

# Monitor Diagnostic Setting
# resource "azurerm_monitor_diagnostic_setting" "agw" {
#   name                       = "${var.application_gateway.name}-diagnostics"
#   target_resource_id         = azurerm_application_gateway.agw.id
#   log_analytics_workspace_id = var.diagnostics.log_analytics_workspace_id

#   dynamic "metric" {
#     for_each = var.diagnostics.metrics
#     content {
#       category = metric.value
#       enabled  = true

#       retention_policy {
#         enabled = var.diagnostics.retention_policy.enabled
#         days    = var.diagnostics.retention_policy.days
#       }
#     }
#   }

#   dynamic "log" {
#     for_each = var.diagnostics.logs
#     content {
#       category = log.value
#       enabled  = true

#       retention_policy {
#         enabled = var.diagnostics.retention_policy.enabled
#         days    = var.diagnostics.retention_policy.days
#       }
#     }
#   }
# }
