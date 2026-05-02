output "resource_name_prefix" {
  description = "Standard resource name prefix: <company_code>-<env_short>-<location_short>-<resource_type_short>"
  value       = var.resource_type == "container_registry" || var.resource_type == "virtual_machine" || var.resource_type == "container_app" ? "${var.company_code}${local.env_short_code}${local.location_short_code}${local.resource_type_short_code}" : "${var.company_code}-${local.env_short_code}-${local.location_short_code}-${local.resource_type_short_code}"
}
