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
            version = "~> 4.43.0"
        }
    }

}

provider "azurerm" {
    features {}
}

provider "azuread" {
  # Authenticate using environment variables:
  # AZURE_CLIENT_ID, AZURE_CLIENT_SECRET, AZURE_TENANT_ID
}

resource "azurerm_resource_group" "rg" {
    name     = "rg-audiobooks-app"
    location = "East US"
}

data "azurerm_client_config" "current" {}






