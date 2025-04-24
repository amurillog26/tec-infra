# main.tf
locals {
  firewall_rules = merge([
    for redis_key, redis in var.redis_cache : {
      for rule_key, rule in lookup(redis, "firewall_rules", {}) : 
      "${redis_key}-${rule_key}" => {
        redis_name = redis.name
        name       = rule_key
        start_ip   = rule.start_ip
        end_ip     = rule.end_ip
      }
    } if !lookup(redis, "is_enterprise", false)
  ]...)
}

# Standard Redis Cache resource
resource "azurerm_redis_cache" "redis" {
  for_each = {
    for k, v in var.redis_cache : k => v if !lookup(v, "is_enterprise", false)
  }

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = each.value.capacity
  family              = each.value.family
  sku_name            = each.value.sku_name
  minimum_tls_version = lookup(each.value, "minimum_tls_version", "1.2")
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", false)
  non_ssl_port_enabled = lookup(each.value, "non_ssl_port_enabled", false)

  dynamic "redis_configuration" {
    for_each = lookup(each.value, "redis_configuration", null) != null ? [1] : []
    content {
      maxmemory_policy               = lookup(each.value.redis_configuration, "maxmemory_policy", "volatile-lru")
      maxfragmentationmemory_reserved = lookup(each.value.redis_configuration, "maxfragmentationmemory_reserved", null)
      maxmemory_reserved             = lookup(each.value.redis_configuration, "maxmemory_reserved", null)
      data_persistence_authentication_method = lookup(each.value.redis_configuration, "data_persistence_authentication_method", null)
    }
  }

  dynamic "patch_schedule" {
    for_each = lookup(each.value, "patch_schedule", null) != null ? [1] : []
    content {
      day_of_week    = each.value.patch_schedule.day_of_week
      start_hour_utc = each.value.patch_schedule.start_hour_utc
    }
  }

  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# NEW: Redis Enterprise Cluster resource
resource "azurerm_redis_enterprise_cluster" "redis_enterprise" {
  for_each = {
    for k, v in var.redis_cache : k => v if lookup(v, "is_enterprise", false)
  }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  # Enterprise SKU must be formatted as: "Enterprise_E<capacity>-<tier>"
  # Example: "Enterprise_E10-2" for a 10GB memory, zone redundant cluster
  sku_name            = each.value.sku_name
  
  minimum_tls_version = lookup(each.value, "minimum_tls_version", "1.2")
  zones               = lookup(each.value, "zones", null)
  
  tags = merge(var.tags, lookup(each.value, "tags", {}))
}

# NEW: Redis Enterprise Database resource
resource "azurerm_redis_enterprise_database" "redis_db" {
  for_each = {
    for k, v in var.redis_cache : k => v if lookup(v, "is_enterprise", false)
  }

  name                = "default"
  cluster_id          = azurerm_redis_enterprise_cluster.redis_enterprise[each.key].id
  client_protocol     = lookup(each.value, "client_protocol", "Encrypted")
  clustering_policy   = lookup(each.value, "clustering_policy", "OSSCluster")
  eviction_policy     = lookup(each.value, "eviction_policy", "NoEviction")
  
  # For Redis Search capability
  module {
    name = "RediSearch"
  }
}

# Firewall Rules for standard Redis Cache
resource "azurerm_redis_firewall_rule" "rules" {
  for_each = local.firewall_rules

  name                = each.value.name
  redis_cache_name    = each.value.redis_name
  resource_group_name = var.resource_group_name
  start_ip           = each.value.start_ip
  end_ip             = each.value.end_ip

  depends_on = [azurerm_redis_cache.redis]
}
