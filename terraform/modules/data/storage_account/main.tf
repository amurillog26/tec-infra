# main.tf
locals {
  # Valores por defecto que se pueden sobrescribir por storage account
  default_config = {
    account_tier             = "Standard"
    account_replication_type = "LRS"
    account_kind            = "StorageV2"
    enable_https_traffic    = true
    min_tls_version        = "TLS1_2"
    access_tier            = "Hot"
    is_hns_enabled        = false
    network_rules = {
      default_action = "Deny"
      ip_rules       = []
      bypass         = ["AzureServices"]
    }
  }
}

resource "azurerm_storage_account" "storage_accounts" {
  for_each = var.storage_accounts

  name                      = each.value.name
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_tier             = coalesce(each.value.account_tier, local.default_config.account_tier)
  account_replication_type = coalesce(each.value.account_replication_type, local.default_config.account_replication_type)
  account_kind            = coalesce(each.value.account_kind, local.default_config.account_kind)
  
  min_tls_version          = coalesce(each.value.min_tls_version, local.default_config.min_tls_version)
  access_tier              = coalesce(each.value.access_tier, local.default_config.access_tier)
  is_hns_enabled          = coalesce(each.value.is_hns_enabled, local.default_config.is_hns_enabled)

  network_rules {
    default_action = coalesce(
      try(each.value.network_rules.default_action, null),
      local.default_config.network_rules.default_action
    )
    ip_rules       = coalesce(
      try(each.value.network_rules.ip_rules, null),
      local.default_config.network_rules.ip_rules
    )
    bypass         = coalesce(
      try(each.value.network_rules.bypass, null),
      local.default_config.network_rules.bypass
    )
  }

  tags = merge(
    var.tags,
    try(each.value.tags, {})
  )

  lifecycle {
    ignore_changes = [
      resource_group_name
    ]
  }
}

# Opcionalmente, crear containers para cada storage account
resource "azurerm_storage_container" "containers" {
  for_each = {
    for container in local.container_list : "${container.storage_account_key}.${container.container_name}" => container
  }

  name                  = each.value.container_name
  storage_account_name = azurerm_storage_account.storage_accounts[each.value.storage_account_key].name
  container_access_type = try(each.value.access_type, "private")
}

# Procesar la lista de containers
locals {
  container_list = flatten([
    for sa_key, sa in var.storage_accounts : [
      for container in try(sa.containers, []) : {
        storage_account_key = sa_key
        container_name     = container.name
        access_type       = try(container.access_type, "private")
      }
    ]
  ])
}
