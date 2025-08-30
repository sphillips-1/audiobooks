terraform {
    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }
    required_version = ">= 1.1.0"
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "rg" {
    name     = "rg-audiobooks-app"
    location = "East US"
}

resource "azurerm_storage_account" "storage" {
    name                     = "audiobooksstorage"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

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

data "azurerm_client_config" "current" {}
resource "azurerm_container_registry" "acr" {
    name                = "audiobooksacr"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Basic"
    admin_enabled       = true
}