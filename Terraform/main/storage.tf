resource "azurerm_storage_account" "main" {
  name                     = "saaudiobooksean"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # Required to support >2MB files
  large_file_share_enabled = true

}

resource "azurerm_storage_share" "media" {
  name               = "abs-media"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 5120  # 5 TB for audiobooks
  enabled_protocol     = "SMB" # ensure SMB access is enabled
}

resource "azurerm_storage_share" "config" {
  name               = "abs-config"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 100  # small, just for metadata/db
}

resource "azurerm_storage_share" "nginx_config" {
  name               = "nginx-config"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 10   # small, just for nginx.conf
}

resource "azurerm_storage_share" "nginx_cert" {
  name               = "nginx-cert"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 10   # small, just for SSL certs
}