# Create new user resources
variable "dd_users" {
  description = "Map of User Resources"
  type = map(object({
    email    = string
    roles    = optional(list(string), [])
    disabled = optional(bool, false)
  }))

  default = {
    "jconway" = {
      email    = "jconway@linuxfoundation.org"
      roles    = ["admin"]
      disabled = false
    },
    "tha" = {
      email    = "tha@linuxfoundation.org"
      roles    = ["admin"]
      disabled = false
    },
    "rdetjens" = {
      email    = "rdetjens@linuxfoundation.org"
      roles    = ["admin"]
      disabled = false
    },
    "rgrigar" = {
      email    = "rgrigar@linuxfoundation.org"
      roles    = ["admin"]
      disabled = false
    }
  }
}
resource "datadog_user" "users" {
  for_each = var.dd_users
  email    = each.value.email
  roles    = each.value.roles
  disabled = each.value.disabled
}
