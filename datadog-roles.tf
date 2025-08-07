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
        data.datadog_permissions.permissions.permissions["logs_read_data"],
        data.datadog_permissions.permissions.permissions["logs_read_index_data"],
        data.datadog_permissions.permissions.permissions["logs_read_archives"],
        data.datadog_permissions.permissions.permissions["synthetics_read"],
        data.datadog_permissions.permissions.permissions["cases_read"],
        data.datadog_permissions.permissions.permissions["audit_logs_read"],

        # Additional write permissions
        data.datadog_permissions.permissions.permissions["dashboards_write"],
        data.datadog_permissions.permissions.permissions["dashboards_public_share"],
        data.datadog_permissions.permissions.permissions["monitors_write"],
        data.datadog_permissions.permissions.permissions["synthetics_write"],
        data.datadog_permissions.permissions.permissions["cases_write"],
        data.datadog_permissions.permissions.permissions["notebooks_write"],
        data.datadog_permissions.permissions.permissions["incident_write"],
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