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
        "dashboards_read",
        "monitors_read",
        "logs_read_data",
        "logs_read_index_data",
        "logs_read_archives",
        "apm_read",
        "metrics_read",
        "synthetics_read",
        "incidents_read",
        "cases_read",
        "notebooks_read",
        
        # Additional write permissions
        "dashboards_write",
        "dashboards_public_share",
        "notebooks_write",
        "monitors_write",
        "synthetics_write",
        "incidents_write",
        "cases_write"
      ]
    }
    
    # Example role configuration - replace with actual roles
    # "custom-readonly" = {
    #   name        = "Custom Read Only"
    #   permissions = [
    #     "dashboards_read",
    #     "monitors_read",
    #     "logs_read_data"
    #   ]
    # },
    # "custom-admin" = {
    #   name        = "Custom Admin"
    #   permissions = [
    #     "admin",
    #     "dashboards_write",
    #     "monitors_write",
    #     "logs_write_exclusion_filters"
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
