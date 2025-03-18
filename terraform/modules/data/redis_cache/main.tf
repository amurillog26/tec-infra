# main.tf
locals {
  firewall_rules = merge([
    for redis_key, redis in var.redis_cache : {
      for rule_key, rule in redis.firewall_rules : 
      "${redis_key}-${rule_key}" => {
        redis_name = redis.name
        name       = rule_key
        start_ip   = rule.start_ip
        end_ip     = rule.end_ip
      }
    }
  ]...)
}

resource "azurerm_redis_cache" "redis" {
  for_each = var.redis_cache

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = each.value.capacity
  family              = each.value.family
  sku_name            = each.value.sku_name
  minimum_tls_version = each.value.minimum_tls_version
  public_network_access_enabled = false

  redis_configuration {
    maxmemory_policy               = each.value.redis_configuration.maxmemory_policy
    maxfragmentationmemory_reserved = each.value.redis_configuration.maxfragmentationmemory_reserved
    maxmemory_reserved             = each.value.redis_configuration.maxmemory_reserved
  }

  patch_schedule {
    day_of_week    = each.value.patch_schedule.day_of_week
    start_hour_utc = each.value.patch_schedule.start_hour_utc
  }

  tags = merge(var.tags, each.value.tags)
}

# Firewall Rules
resource "azurerm_redis_firewall_rule" "rules" {
  for_each = local.firewall_rules

  name                = each.value.name
  redis_cache_name    = each.value.redis_name
  resource_group_name = var.resource_group_name
  start_ip           = each.value.start_ip
  end_ip             = each.value.end_ip

  depends_on = [azurerm_redis_cache.redis]
}

# # Monitor Diagnostic Setting
# resource "azurerm_monitor_diagnostic_setting" "redis" {
#   for_each = var.redis_cache

#   name                       = "${each.value.name}-diagnostics"
#   target_resource_id         = azurerm_redis_cache.redis[each.key].id
#   log_analytics_workspace_id = var.diagnostics.log_analytics_workspace_id

#   dynamic "metric" {
#     for_each = var.diagnostics.metrics
#     content {
#       category = metric.value
#       enabled  = true

#     }
#   }

#   dynamic "log" {
#     for_each = var.diagnostics.logs
#     content {
#       category = log.value
#       enabled  = true

#     }
#   }
# }
