locals {
  # Mapping of resource types to their Azure Private DNS zone names
  dns_zone_map = {
    blob               = "privatelink.blob.core.windows.net"
    file               = "privatelink.file.core.windows.net"
    queue              = "privatelink.queue.core.windows.net"
    table              = "privatelink.table.core.windows.net"
    dfs                = "privatelink.dfs.core.windows.net"
    web                = "privatelink.web.core.windows.net"
    container_registry = "privatelink.azurecr.io"
    key_vault          = "privatelink.vaultcore.azure.net"
    sql_server         = "privatelink.database.windows.net"
    cosmos_db          = "privatelink.documents.azure.com"
    service_bus        = "privatelink.servicebus.windows.net"
    event_hub          = "privatelink.servicebus.windows.net"
    app_service        = "privatelink.azurewebsites.net"
    cognitive_services = "privatelink.cognitiveservices.azure.com"
    aks                = "privatelink.azmk8s.io"
    redis_cache        = "privatelink.redis.cache.windows.net"
    monitor            = "privatelink.monitor.azure.com"
    container_app      = "privatelink.${var.location}.azurecontainerapps.io"
  }
}
