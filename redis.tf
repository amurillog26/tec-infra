module "redis" {
  source = "./terraform/modules/data/redis_cache"

  resource_group_name = var.resource_group_name
  location            = var.location

  redis_cache = var.redis_cache
  tags        = var.tags
}
