

resource "azurerm_container_group" "aci" {
    name                = "audiobooks-aci"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type             = "Linux"
    ip_address_type = "Public"
    dns_name_label  = "audiobooks-sean"

    container {
        name   = "audiobooks"
        image  = "ghcr.io/advplyr/audiobookshelf:latest"
        cpu    = "0.25"
        memory = "0.5"
        environment_variables = {
            OIDC_CLIENT_ID     = azuread_application.abs.client_id
            OIDC_CLIENT_SECRET = azuread_application_password.abs_secret.value
            OIDC_ISSUER        = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
            OIDC_REDIRECT_URI  = "https://audiobooks-aci.eastus.azurecontainer.io/auth/openid/callback"
        }

        ports {
            port     = 80
            protocol = "TCP"
        }

        # Define and mount media share volume here
        volume {
            name                   = "media"
            mount_path             = "/audiobooks"
            share_name             = azurerm_storage_share.media.name
            storage_account_name   = azurerm_storage_account.main.name
            storage_account_key    = azurerm_storage_account.main.primary_access_key
            read_only              = false
        }

        # Define and mount config share volume here
        volume {
            name                   = "config"
            mount_path             = "/config"
            share_name             = azurerm_storage_share.config.name
            storage_account_name   = azurerm_storage_account.main.name
            storage_account_key    = azurerm_storage_account.main.primary_access_key
            read_only              = false
        }
    }

    tags = { app = "audiobookshelf" }
}





