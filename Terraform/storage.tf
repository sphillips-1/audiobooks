resource "azurerm_storage_account" "main" {
  name                     = "saaudiobooksean"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  large_file_share_enabled = true
}

resource "azurerm_storage_share" "media" {
  name                 = "abs-media"
  storage_account_id = azurerm_storage_account.main.id
  quota                = 5120 # GB
}

resource "azurerm_storage_share" "config" {
  name                 = "abs-config"
  storage_account_id = azurerm_storage_account.main.id
  quota                = 100
}