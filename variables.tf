# SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
#
# SPDX-License-Identifier: Apache-2.0

variable "run_manually" {
  description = "Flag for manual Terraform runs"
  type        = bool
  default     = false
}

variable "environment_tag" {
  description = "Mapping of environment names to their corresponding tags"
  type        = map(string)
  default = {
    dev     = "development"
    prod    = "production"
    staging = "staging"
  }
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog application key"
  type        = string
  sensitive   = true
}

variable "incident_io_bearer" {
  description = "Bearer token for Incident.io webhook authorization"
  type        = string
  sensitive   = true
}
