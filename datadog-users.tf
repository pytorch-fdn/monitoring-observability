# SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
#
# SPDX-License-Identifier: Apache-2.0

# Source a role
data "datadog_role" "admin_role" {
  filter = "Datadog Admin Role"
}
#Uncomment if you need to source other roles
#data "datadog_role" "ro_role" {
#  filter = "Datadog Read Only Role"
#}
#data "datadog_role" "standard_role" {
#  filter = "Datadog Standard Role"
#}

# Create new user resources
variable "dd_users" {
  description = "Map of User Resources"
  type = map(object({
    email    = string
    roles    = optional(list(string), [])
    disabled = optional(bool, false)
  }))

  default = {}
}

locals {
  default_users = {
    "jconway" = {
      email    = "jconway@linuxfoundation.org"
      roles    = [data.datadog_role.admin_role.id]
      disabled = false
    },
    "tha" = {
      email    = "thanh.ha@linuxfoundation.org"
      roles    = [data.datadog_role.admin_role.id]
      disabled = false
    },
    "rdetjens" = {
      email    = "rdetjens@linuxfoundation.org"
      roles    = [data.datadog_role.admin_role.id]
      disabled = false
    },
    "rgrigar" = {
      email    = "rgrigar@linuxfoundation.org"
      roles    = [data.datadog_role.admin_role.id]
      disabled = false
    } #,
    #"amdfaa" = {
    #  email    = "Faa.Diallo@linuxfoundation.org"
    #  roles    = [datadog_role.roles["custom-read-write"].id]
    #  disabled = false
    #}
  }

  # Merge default users with any custom users provided via variable
  users = merge(local.default_users, var.dd_users)
}

resource "datadog_user" "users" {
  for_each = local.users
  email    = each.value.email
  roles    = each.value.roles
  disabled = each.value.disabled
}
