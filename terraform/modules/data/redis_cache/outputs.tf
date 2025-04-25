
# outputs.tf
output "redis_cache_ids" {
  value = {
    for k, v in azurerm_redis_cache.redis : k => v.id
  }
  description = "The IDs of the Redis Caches"
}

output "redis_cache_hostnames" {
  value = {
    for k, v in azurerm_redis_cache.redis : k => v.hostname
  }
  description = "The hostnames of the Redis Caches"
}

output "redis_cache_ssl_ports" {
  value = {
    for k, v in azurerm_redis_cache.redis : k => v.ssl_port
  }
  description = "The SSL ports of the Redis Caches"
}

output "redis_cache_connection_strings" {
  value = {
    for k, v in azurerm_redis_cache.redis : k => v.primary_connection_string
  }
  sensitive = true
  description = "The primary connection strings of the Redis Caches"
}
