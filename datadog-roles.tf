# check permissions
data "datadog_permissions" "permissions" {}

# Create new role resources
variable "dd_roles" {
  description = "Map of Role Resources"
  type = map(object({
    name        = string
    permissions = optional(list(string), [])
  }))

  default = {
    "custom-read-write" = {
      name = "Custom Read Write"
      permissions = [
        # Read permissions (similar to read-only role)
        data.datadog_permissions.permissions.dashboards_read.id,
        data.datadog_permissions.permissions.monitors_read.id,
        data.datadog_permissions.permissions.logs_read_index_data.id,
        data.datadog_permissions.permissions.logs_read_archives.id,
        data.datadog_permissions.permissions.apm_read.id,
        data.datadog_permissions.permissions.metrics_read.id,
        data.datadog_permissions.permissions.synthetics_read.id,
        data.datadog_permissions.permissions.incidents_read.id,
        data.datadog_permissions.permissions.cases_read.id,
        data.datadog_permissions.permissions.notebooks_read.id,

        # Additional write permissions
        data.datadog_permissions.permissions.dashboards_write.id,
        data.datadog_permissions.permissions.monitors_write.id,
        data.datadog_permissions.permissions.synthetics_write.id,
        data.datadog_permissions.permissions.cases_write.id,
        data.datadog_permissions.permissions.notebooks_write.id,
        data.datadog_permissions.permissions.incidents_write.id
      ]
    }
    
    # Example role configuration - replace with actual roles
    # "custom-readonly" = {
    #   name        = "Custom Read Only"
    #   permissions = [
    #     data.datadog_permissions.permissions.dashboards_read.id,
    #     data.datadog_permissions.permissions.monitors_read.id,
    #     data.datadog_permissions.permissions.logs_read_data.id
    #   ]
    # },
    # "custom-admin" = {
    #   name        = "Custom Admin"
    #   permissions = [
    #     data.datadog_permissions.permissions.admin.id,
    #     data.datadog_permissions.permissions.dashboards_write.id,
    #     data.datadog_permissions.permissions.monitors_write.id,
    #     data.datadog_permissions.permissions.logs_write_exclusion_filters.id
    #   ]
    # }
  }
}

resource "datadog_role" "roles" {
  for_each = var.dd_roles
  name     = each.value.name

  dynamic "permission" {
    for_each = each.value.permissions
    content {
      id = permission.value
    }
  }
}
