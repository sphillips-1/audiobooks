resource "azurerm_container_group" "aci" {
    name                = "audiobooks-aci"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type             = "Linux"

    container {
        name   = "audiobooks"
        image  = "ghcr.io/advplyr/audiobookshelf:latest"
        cpu    = "1.0"
        memory = "1.5"

        environment_variables = {
        }

        ports {
            port     = 80
            protocol = "TCP"
        }
    }

    image_registry_credential {
        server   = azurerm_container_registry.acr.login_server
        username = azurerm_container_registry.acr.admin_username
        password = azurerm_container_registry.acr.admin_password
    }

    ip_address_type = "Public"
    dns_name_label  = "audiobooks-aci-${random_id.dns.hex}"
}

resource "random_id" "dns" {
    byte_length = 4
}

