# Create new user resources
variable "dd_users" {
  description = "Map of User Resources"
  type = map(object({
    email    = string
    name     = string
    roles    = optional(list(string), [])
    disabled = optional(bool, false)
  }))

  default = {
    # Example user configuration - replace with actual users
    # "example-user" = {
    #   email    = "user@example.com"
    #   name     = "Example User"
    #   roles    = ["standard"]  # roles can include: "standard", "admin", "read_only"
    #   disabled = false
    # }
  }
}

resource "datadog_user" "users" {
  for_each = var.dd_users
  email    = each.value.email
  name     = each.value.name
  roles    = each.value.roles
  disabled = each.value.disabled
}
