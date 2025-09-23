# -------------------------
# 5️⃣ Outputs for Audiobookshelf
# -------------------------
output "abs_client_id" {
  description = "Azure AD Client ID for Audiobookshelf"
  value       = azuread_application.abs.client_id
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