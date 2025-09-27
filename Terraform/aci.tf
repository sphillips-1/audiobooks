resource "azurerm_container_group" "aci" {
  name                = "audiobookshelf-aci"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = "audiobookshelf-sean"

  container {
    name   = "nginx"
    image  = "nginx:latest"
    cpu    = "0.1"
    memory = "0.2"
    ports {
      port     = 443
      protocol = "TCP"
    }
    volume {
      name                 = "nginx-config"
      mount_path           = "/etc/nginx/conf.d"
      share_name           = azurerm_storage_share.nginx_config.name
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
      read_only            = false
    }
    volume {
      name                 = "nginx-cert"
      mount_path           = "/etc/nginx/certs"
      share_name           = azurerm_storage_share.nginx_cert.name
      storage_account_name = azurerm_storage_account.main.name
      storage_account_key  = azurerm_storage_account.main.primary_access_key
      read_only            = false
    }
  }

  container {
    name   = "audiobookshelf"
    image  = "ghcr.io/advplyr/audiobookshelf:latest"
    cpu    = "0.1"
    memory = "0.2"
    ports {
      port     = 80
      protocol = "TCP"
    }
  }

}

# Place your SSL cert and nginx.conf in the Azure File Share.
# nginx.conf should proxy HTTPS to audiobookshelf container on port 80.
