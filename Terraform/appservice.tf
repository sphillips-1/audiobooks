resource "azurerm_app_service_plan" "asp" {
    name                = "audiobooks-appserviceplan"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku {
        tier = "Basic"
        size = "B1"
    }
}

resource "azurerm_app_service" "app" {
    name                = "audiobooks-appservice"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    app_service_plan_id = azurerm_app_service_plan.asp.id

    identity {
        type = "SystemAssigned"
    }

    site_config {
        linux_fx_version = "DOCKER|${azurerm_container_registry.acr.login_server}/your-image:latest"
        acr_use_managed_identity_credentials = true
        acr_user_managed_identity_client_id  = null
    }

    app_settings = {
        "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.acr.login_server}"
        "DOCKER_REGISTRY_SERVER_USERNAME" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.acr_username.id})"
        "DOCKER_REGISTRY_SERVER_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.acr_password.id})"
    }
}