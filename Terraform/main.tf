terraform {
    required_version = "~> 1.13.0"
    backend "azurerm" {
        storage_account_name  = "satfstateeast"
        container_name        = "tfstate-audiobooks"
        key                   = "audiobooks.tfstate"
        resource_group_name   = "rg-Terraform-Requirements"
    }

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~> 3.0"
        }
    }

}

provider "azurerm" {
    features {}
}

resource "random_id" "dns" {
    byte_length = 4
}

resource "azurerm_resource_group" "rg" {
    name     = "rg-audiobooks-app"
    location = "East US"
}

data "azurerm_client_config" "current" {}

resource "azurerm_container_registry" "acr" {
    name                = "audiobooksacr"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    sku                 = "Basic"
    admin_enabled       = true
}