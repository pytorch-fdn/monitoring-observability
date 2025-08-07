# check permissions
data "datadog_permissions" "permissions" {}

# Create new role resources
variable "dd_roles" {
  description = "Map of Role Resources"
  type = map(object({
    name        = string
    permissions = optional(list(string), [])
  }))

  default = {}
}

locals {
  default_roles = {
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
  }

  # Merge default roles with any custom roles provided via variable
  roles = merge(local.default_roles, var.dd_roles)
}

resource "datadog_role" "roles" {
  for_each = local.roles
  name     = each.value.name

  dynamic "permission" {
    for_each = each.value.permissions
    content {
      id = permission.value
    }
  }
}
