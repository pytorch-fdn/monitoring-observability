# SPDX-FileCopyrightText: 2025 The Linux Foundation
#
# SPDX-License-Identifier: Apache-2.0

# IAM role to assume for manual Terraform runs using Makefile
variable "provider_assume_role" {
  description = "ARN of the IAM role to assume for manual Terraform runs using Makefile"
  type        = map(string)
  default = {
    prod = "arn:aws:iam::391835788720:role/lfit-sysadmins-mfa"
  }
}

# Roles to assume for Github Actions
variable "provider_assume_role_ci" {
  description = "ARN of the IAM role to assume for CI/CD, depending on the environment"
  type        = map(string)
  default = {
    prod = "arn:aws:iam::391835788720:role/terraform-deploy-oidc"
  }
}

# Skip the provider's nested assume_role and use the ambient credentials
# instead. Used by gated fork plans, which run as the read-only
# terraform-plan-oidc role: that role deliberately cannot assume the
# terraform-deploy-oidc role, and the only AWS call the config makes is the
# unprivileged aws_caller_identity data source, so no role hop is needed.
variable "provider_skip_assume_role" {
  description = "Skip the AWS provider assume_role and use ambient credentials (gated fork plans running as terraform-plan-oidc)"
  type        = bool
  default     = false
}

# Pick the right IAM role based on the run_manually flag
locals {
  role_to_assume = var.run_manually ? var.provider_assume_role[terraform.workspace] : var.provider_assume_role_ci[terraform.workspace]
}

# Default AWS provider.
provider "aws" {
  region = "us-west-2"

  dynamic "assume_role" {
    for_each = var.provider_skip_assume_role ? [] : [1]
    content {
      role_arn     = local.role_to_assume
      session_name = "terraform"
    }
  }

  default_tags {
    tags = {
      env     = var.environment_tag[terraform.workspace]
      product = "pytorch"
      owner   = "LF CloudOps"
      repo    = "pytorch-fdn/datadog-terraform"
    }
  }
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.us3.datadoghq.com"
}

# State storage.
terraform {
  backend "s3" {
    region = "us-west-2"
    key    = "terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "3.91.0"
    }

  }
  required_version = "~> 1.1"
}
