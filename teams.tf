# Create new team resource
variable "teams" {
  description = "Map of Team Resources"
  type = map(object({
    name        = string
    description = string
    handle      = string
  }))

  default = {
    lf-staff = {
      description = "Linux Foundaiton Staff Members"
      name        = "LF Staff"
      handle      = "lf-staff"
    },
    meta-staff = {
      description = "Meta Staff Members"
      name        = "Meta Staff"
      handle      = "meta-staff"
    },
    amd-staff = {
      description = "AMD Staff Members"
      name        = "AMD Staff"
      handle      = "amd-staff"
    },
    nvidia-staff = {
      description = "Nvidia Staff Members"
      name        = "Nvidia Staff"
      handle      = "nvidia-staff"
    },
    ibm-staff = {
      description = "IBM Staff Members"
      name        = "IBM Staff"
      handle      = "ibm-staff"
    }
  }
}

resource "datadog_team" "teams" {
  for_each    = var.teams
  description = each.value.description
  handle      = each.value.handle
  name        = each.value.name
}
