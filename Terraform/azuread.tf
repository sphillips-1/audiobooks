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
      "https://audiobooks-aci.eastus.azurecontainer.io/auth/openid/callback",
      "https://audiobooks-aci.eastus.azurecontainer.io/",
      "audiobookshelf://auth"
    ]
    logout_url = "https://${azurerm_container_group.aci.fqdn}/logout"
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
  client_id = azuread_application.abs.client_id
}

# -------------------------
# 3️⃣ Client Secret
# -------------------------
resource "azuread_application_password" "abs_secret" {
  application_id = azuread_application.abs.id
  display_name   = "ABS Terraform Secret"
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