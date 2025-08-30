resource "azurerm_key_vault" "kv" {
    name                        = "audiobookskeyvault"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    sku_name                    = "standard"
    purge_protection_enabled    = false
    soft_delete_enabled         = true

    access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = azurerm_app_service.app.identity.principal_id

        secret_permissions = [
            "get", "list"
        ]
    }
}

resource "azurerm_key_vault_secret" "acr_username" {
    name         = "acr-username"
    value        = azurerm_container_registry.acr.admin_username
    key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "acr_password" {
    name         = "acr-password"
    value        = azurerm_container_registry.acr.admin_password
    key_vault_id = azurerm_key_vault.kv.id
}