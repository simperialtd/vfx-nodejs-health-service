# Assigning the "Desktop Virtualization User" role to users/groups for each AVD application group
resource "azurerm_role_assignment" "application_group_assignment" {
  for_each = merge([
    for dag in var.application_groups : {
      for principal_id in dag.assignment_principal_ids :
      "${dag.suffix}|${principal_id}" => { principal_id = principal_id, dag_suffix = dag.suffix }
    }
  ]...)

  scope                = azurerm_virtual_desktop_application_group.this[each.value.dag_suffix].id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = each.value.principal_id
}


resource "azurerm_role_assignment" "resource_group_assignment" {
  for_each = merge([
    for dag in var.application_groups : {
      for principal_id in dag.assignment_principal_ids :
      "${dag.suffix}|${principal_id}" => { principal_id = principal_id, dag_suffix = dag.suffix }
    }
  ]...)
  scope                = var.session_hosts_resource_group_id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = each.value.principal_id
}
