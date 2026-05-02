output "private_dns_zones" {
  description = "Private DNS zone details (id, name) keyed by zone type"
  value = {
    for zone in var.zone_types : zone => {
      id   = azurerm_private_dns_zone.this[zone].id
      name = azurerm_private_dns_zone.this[zone].name
    }
  }
}
