# -------------------------
# 5️⃣ Outputs for Audiobookshelf
# -------------------------
output "abs_client_id" {
  description = "Azure AD Client ID for Audiobookshelf"
  value       = azuread_application.main.client_id
}

output "abs_client_secret" {
  description = "Azure AD Client Secret for Audiobookshelf"
  value       = azuread_application_password.main.value
  sensitive   = true
}

output "abs_tenant_id" {
  description = "Tenant ID (used in Issuer URL)"
  value       = data.azuread_client_config.current.tenant_id
}

output "abs_redirect_uri" {
  description = "Redirect URI for Audiobookshelf (used in OIDC settings)"
  value       = "https://${azurerm_container_group.main.dns_name_label}.${azurerm_container_group.main.location}.azurecontainer.io/auth/openid/callback"
}