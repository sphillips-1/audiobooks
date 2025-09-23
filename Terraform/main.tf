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

# -------------------------
# 1️⃣ Audiobookshelf App Registration
# -------------------------
resource "azuread_application" "abs" {
  display_name     = "Audiobookshelf OIDC"
  # ✅ Allow both organizational accounts and personal Microsoft accounts
  sign_in_audience = "AzureADMultipleOrgs"

  # ✅ OIDC web app configuration with both web and mobile redirect URIs
  web {
    redirect_uris = [
      azurerm_container_group.aci.fqdn + "/auth/openid/callback", # Replace with your ABS URL
      "audiobookshelf://auth"                        # Mobile app redirect
    ]
    logout_url = azurerm_container_group.aci.fqdn + "/logout"
  }

  # Optional: Request basic Microsoft Graph permissions
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # User.Read scope
      type = "Scope"
    }
  }
}

# -------------------------
# 2️⃣ Service Principal
# -------------------------
resource "azuread_service_principal" "abs" {
  application_id = azuread_application.abs.application_id
}

# -------------------------
# 3️⃣ Client Secret
# -------------------------
resource "azuread_application_password" "abs_secret" {
  application_object_id = azuread_application.abs.object_id
  display_name          = "ABS Terraform Secret"
}

# -------------------------
# 4️⃣ Optional Claims (include email claim in ID token)
# -------------------------
resource "azuread_application_optional_claims" "abs" {
  application_id = azuread_application.abs.id

  id_token {
    name = "email"
  }
}

# -------------------------
# 5️⃣ Outputs for Audiobookshelf
# -------------------------
output "abs_client_id" {
  description = "Azure AD Client ID for Audiobookshelf"
  value       = azuread_application.abs.application_id
}

output "abs_client_secret" {
  description = "Azure AD Client Secret for Audiobookshelf"
  value       = azuread_application_password.abs_secret.value
  sensitive   = true
}

output "abs_tenant_id" {
  description = "Tenant ID (used in Issuer URL)"
  value       = data.azuread_client_config.current.tenant_id
}
