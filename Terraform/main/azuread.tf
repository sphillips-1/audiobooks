# -------------------------
# 1️⃣ Audiobookshelf App Registration
# -------------------------
resource "azuread_application" "main" {
  display_name     = "Audiobookshelf OIDC"
  # ✅ Allow both organizational accounts and personal Microsoft accounts
  sign_in_audience = "AzureADMultipleOrgs"

  # ✅ OIDC web app configuration with both web and mobile redirect URIs
  web {
    redirect_uris = [
      "https://localhost/",
      "https://localhost/auth/openid/callback"
    ]
    logout_url = "https://localhost/logout"
  }

  # Optional: Request basic Microsoft Graph permissions
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # User.Read
      type = "Scope"
    }
  }
}

# -------------------------
# 2️⃣ Service Principal
# -------------------------
resource "azuread_service_principal" "main" {
  client_id = azuread_application.main.client_id
}

# -------------------------
# 3️⃣ Client Secret
# -------------------------
resource "azuread_application_password" "main" {
  application_id = azuread_application.main.id
  display_name   = "ABS Terraform Secret"
}

# -------------------------
# 4️⃣ Optional Claims (include email claim in ID token)
# -------------------------
resource "azuread_application_optional_claims" "main" {
  application_id = azuread_application.main.id

  id_token {
    name = "email"
  }
}