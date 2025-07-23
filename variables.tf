variable "run_manually" {
  description = "Flag for manual TF runs"
  type        = bool
  default     = false
}

variable "environment_tag" {
  default = {
    dev     = "development"
    prod    = "production"
    staging = "staging"
  }
}
