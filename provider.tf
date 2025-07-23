# Change role based on terraform workspace
variable "provider_assume_role" {
  default = {
    prod = "arn:aws:iam::716487311010:role/lfit-sysadmins-mfa" # prdct-prod
    dev  = "arn:aws:iam::395594542180:role/lfit-sysadmins-mfa" # prdct-dev
  }
}

# Roles to assume to Github Actions
variable "provider_assume_role_ci" {
  description = "ARN for PRDCT AWS accounts depending on Environment"
  type        = map(string)
  default = {
    prod = "arn:aws:iam::716487311010:role/terraform-deploy-oidc" # prdct-prod
    dev  = "arn:aws:iam::395594542180:role/terraform-deploy-oidc" # prdct-dev
  }
}

# Pick the right IAM role if run_manually is set
locals {
  prdct_role = var.run_manually ? var.provider_assume_role[terraform.workspace] : var.provider_assume_role_ci[terraform.workspace]
}

# Default AWS provider.
provider "aws" {
  region = "us-east-2"

  assume_role {
    role_arn     = local.prdct_role
    session_name = "terraform"
  }

  default_tags {
    tags = {
      env     = "${var.environment_tag[terraform.workspace]}"
      product = "datalake"
      owner   = "CloudOps"
      repo    = "LF-Engineering/lfx-dbaas-terraform"
    }
  }

}

# State storage.
terraform {
  backend "s3" {
    region = "us-east-2"
    key    = "terraform.tfstate"
  }
  required_version = "~> 1.0"
}
