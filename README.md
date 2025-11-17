<!--
SPDX-FileCopyrightText: 2025 2025 The Linux Foundation

SPDX-License-Identifier: Apache-2.0
-->

# PyTorch Monitoring & Observation Infrastructure

This repository contains Terraform configurations for managing Datadog
monitoring and observability infrastructure for the PyTorch Foundation

## Overview

This infrastructure-as-code setup manages:

- **Datadog Users**: User accounts and role assignments
- **Datadog Roles**: Custom role definitions and permissions
- **Monitoring Resources**: Datadog monitors, dashboards, synthetics

[Back to top](#table-of-contents)

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Structure](#structure)
- [Configuration](#configuration)
  - [Variables Reference](#variables-reference)
    - [User Variables (`dd_users`)](#user-variables-dd_users)
    - [Role Variables (`dd_roles`)](#role-variables-dd_roles)
  - [Available Permissions](#available-permissions)
  - [Custom Roles](#custom-roles)
- [Usage](#usage)
  - [Adding Yourself as a User](#adding-yourself-as-a-user)
  - [Using Existing Datadog Roles](#using-existing-datadog-roles)
  - [Adding Multiple Users](#adding-multiple-users)
  - [Creating Custom Roles](#creating-custom-roles)
- [Monitoring and Alerts](#monitoring-and-alerts)
  - [Synthetics website and API checks](#synthetics-website-and-api-checks)
  - [GitHub ci-sev issues check](#github-ci-sev-issues-check)
  - [Synthetics queue checks (scripts/)](#synthetics-queue-checks-scripts)
  - [Datadog monitors (ALI/GitHub API)](#datadog-monitors-aligithub-api)
- [Deployment](#deployment)
  - [Automated Deployment via GitHub Actions](#automated-deployment-via-github-actions)
  - [GitHub Actions Workflow](#github-actions-workflow)
  - [Code Quality Requirements](#code-quality-requirements)
    - [Manual Validation (Optional)](#manual-validation-optional)
  - [Manual Deployment Steps (for testing)](#manual-deployment-steps-for-testing)
- [Accessing Datadog](#accessing-datadog)
  - [Single Sign-On (SSO) Login](#single-sign-on-sso-login)
  - [First-Time Access](#first-time-access)
  - [Troubleshooting Access](#troubleshooting-access)
  - [Role Capabilities](#role-capabilities)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Getting Help](#getting-help)
- [Contributing](#contributing)
  - [Development Workflow](#development-workflow)
  - [Pre-commit Requirements](#pre-commit-requirements)
  - [Automated Checks](#automated-checks)
  - [MegaLinter Configuration](#megalinter-configuration)

## Prerequisites

- Terraform >= 1.0
- Datadog provider configured
- Appropriate Datadog API and APP keys (handled by CI/CD)
- Access to the PyTorch Datadog organization
- **Valid Linux Foundation ID (LFID)** for SSO access

[Back to top](#table-of-contents)

## Structure

```text
.
├── datadog-users.tf      # User management configuration
├── datadog-roles.tf      # Custom role definitions
├── datadog-monitors.tf   # Monitor and alert definitions
├── datadog-synthetics_tests.tf # Synthetics API tests
├── variables.tf          # Variable definitions (if present)
├── terraform.tfvars      # Variable values (not committed)
├── scripts/              # Synthetics JavaScript checks
└── README.md             # This file
```

[Back to top](#table-of-contents)

## Configuration

### Variables Reference

#### User Variables (`dd_users`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | string | Yes | User's email address |
| `roles` | list(string) | No | List of role IDs to assign (defaults to empty) |
| `disabled` | bool | No | Whether account is disabled (defaults to false) |

#### Role Variables (`dd_roles`)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | Display name for the role |
| `permissions` | list(string) | No | List of permission IDs (defaults empty) |

### Available Permissions

Common permissions you can use in custom roles:

**Read Permissions:**

- `logs_read_data` - Read log data
- `logs_read_index_data` - Read indexed logs  
- `synthetics_read` - View synthetic tests
- `cases_read` - View support cases
- `audit_logs_read` - View audit logs

**Write Permissions:**

- `dashboards_write` - Create/edit dashboards
- `monitors_write` - Create/edit monitors
- `synthetics_write` - Create/edit synthetic tests
- `cases_write` - Create/edit support cases
- `notebooks_write` - Create/edit notebooks
- `incident_write` - Create/edit incidents

### Custom Roles

The repository defines a "Custom Read Write" role (referenced as
"Limited Read Write" in users) that provides:

**Read Permissions:**

- Log data and archives access
- Synthetics monitoring view
- Cases and audit logs access

**Write Permissions:**

- Dashboard creation and editing
- Monitor management
- Synthetics test creation
- Case and notebook management
- Incident response capabilities

[Back to top](#table-of-contents)

## Usage

### Adding Yourself as a User

To add yourself with the "Limited Read Write" role, create or update your
`terraform.tfvars` file:

```hcl
# terraform.tfvars
dd_users = {
  "your-username" = {
    email    = "your.email@example.com"
    roles    = [data.datadog_role.limited_read_write.id]
    disabled = false
  }
}
```

**Example for a new team member:**

```hcl
# terraform.tfvars
dd_users = {
  "jane-smith" = {
    email    = "jane.smith@linuxfoundation.org"
    roles    = [data.datadog_role.limited_read_write.id]
    disabled = false
  },
  "john-doe" = {
    email    = "john.doe@contractor.com"
    roles    = [data.datadog_role.limited_read_write.id]
    disabled = false
  }
}
```

### Using Existing Datadog Roles

To assign existing Datadog roles instead of custom ones:

```hcl
# terraform.tfvars
dd_users = {
  "readonly-user" = {
    email    = "readonly@example.com"
    roles    = [data.datadog_role.ro_role.id]  # Datadog Read Only Role
    disabled = false
  },
  "standard-user" = {
    email    = "standard@example.com"
    roles    = [data.datadog_role.standard_role.id]  # Datadog Standard Role  
    disabled = false
  }
}
```

### Adding Multiple Users

You can add multiple users at once:

```hcl
# terraform.tfvars
dd_users = {
  "team-member-1" = {
    email    = "member1@example.com"
    roles    = [data.datadog_role.limited_read_write.id]
    disabled = false
  },
  "team-member-2" = {
    email    = "member2@example.com" 
    roles    = [data.datadog_role.limited_read_write.id]
    disabled = false
  },
  "contractor" = {
    email    = "contractor@external.com"
    roles    = [data.datadog_role.limited_read_write.id]
    disabled = false
  }
}
```

### Creating Custom Roles

To define additional custom roles:

```hcl
# terraform.tfvars
dd_roles = {
  "developer-role" = {
    name = "Developer Access"
    permissions = [
      "dashboards_read",
      "monitors_read",
      "logs_read_data",
      "synthetics_read"
    ]
  },
  "ops-team-role" = {
    name = "Operations Team"
    permissions = [
      "dashboards_write",
      "monitors_write", 
      "incidents_write",
      "logs_read_data"
    ]
  }
}
```

[Back to top](#table-of-contents)

## Monitoring and Alerts

### Synthetics website and API checks

Synthetic API tests confirm that key PyTorch web properties stay reachable.
The suite probes pytorch.org, docs, download, HUD, landscape, discuss, and
dev-discuss every five minutes, alerting either @slack-pytorch-infra-alerts
or the incident webhook when failures occur.

### GitHub ci-sev issues check

A lightweight synthetic check watches the `ci: sev` GitHub issue queue for
pytorch/pytorch. Any open item triggers @slack-pytorch-infra-alerts so the
team can triage quickly.

### Synthetics queue checks (scripts/)

JavaScript assertions reusable across multiple synthetic tests flag when
GitHub Actions runners stay queued too long. Each script filters for a
vendor-specific `machine_type` pattern, compares queue age against the
threshold defined in the script, and surfaces the human-friendly failure
message in Slack. Sources: `scripts/check-long-queue-*.js`.

### Datadog monitors (ALI/GitHub API)

Metric and event monitors provide coverage for:
- Autoscaler dead-letter queues and validation exceptions
- GitHub API rate spikes affecting autoscaling

Alerts post to `#pytorch-infra-alerts` and the incident webhook so on-call
can jump straight to the relevant dashboards.

[Back to top](#table-of-contents)

## Deployment

### Automated Deployment via GitHub Actions

All infrastructure changes are deployed automatically through GitHub Actions
workflows. The deployment process includes:

1. **Code Quality Checks**: All commits must pass MegaLinter validation
2. **Terraform Planning**: Changes are planned and validated before
   deployment
3. **Automated Apply**: Approved changes are automatically applied to the
   Datadog organization

### GitHub Actions Workflow

The repository uses GitHub Actions with MegaLinter for continuous
deployment:

- **On Pull Request**: Runs MegaLinter suite (includes `tflint`, `tofu fmt`,
  security checks)
- **On Merge to Main**: Automatically applies changes after all checks pass
- **Manual Triggers**: Infrastructure team can manually trigger deployments
  when needed

All commits pushed to any branch must pass the complete MegaLinter
validation suite:

- ✅ **Terraform Formatting** (`tofu fmt`) - Code formatting with
  `tofu fmt`
- ✅ **Terraform Linting** (`tflint`) - Best practices and error detection
- ✅ **Security Scanning** - Infrastructure security checks
- ✅ **Documentation** - README and code documentation validation
- ✅ **Configuration Validation** (`terraform plan`) - Syntax and logic
  validation

Commits that fail MegaLinter checks will be rejected and cannot be merged.

### Code Quality Requirements

Before any deployment, all code must pass **MegaLinter** validation, which
includes:

- **TFLint**: Terraform linting and best practices
- **OpenTofu Formatting**: Code formatting with `tofu fmt`
- **Security Scanning**: Infrastructure security checks
- **Documentation**: README and code documentation validation

#### Manual Validation (Optional)

If you want to run individual checks for troubleshooting:

```bash
# Format all files
tofu fmt

# Check formatting
tofu fmt -check

# Run Terraform linting
tflint
```

### Manual Deployment Steps (for testing)

If you need to test changes locally after MegaLinter validation:

1. **Initialize Terraform:**

   ```bash
   terraform init
   ```

2. **Review the plan:**

   ```bash
   terraform plan
   ```

3. **Apply changes (caution - this affects production):**

   ```bash
   terraform apply
   ```

4. **Verify deployment:**
   Check the Datadog UI to confirm users and roles were created correctly.

[Back to top](#table-of-contents)

## Accessing Datadog

Once your user account has been provisioned through this Terraform
configuration, you can access the PyTorch Datadog organization at:

**<https://datadog.pytorch.org>**

### Single Sign-On (SSO) Login

The PyTorch Datadog organization is integrated with Linux Foundation
Identity (LFID) for authentication:

1. Navigate to <https://datadog.pytorch.org>
2. Click "Login with SSO" or "Single Sign-On"
3. Use your **Linux Foundation ID (LFID)** credentials
4. You will be automatically redirected to Datadog with the appropriate
   role permissions

### First-Time Access

When accessing Datadog for the first time:

1. **Ensure your user is provisioned**: Your email must be added to this
   Terraform configuration and deployed
2. **Use your LFID**: Login with the same email address that was
   provisioned in the Terraform config
3. **Verify permissions**: Check that you can access the appropriate
   dashboards and features based on your assigned role

### Troubleshooting Access

If you cannot access Datadog:

1. **Check user provisioning**: Ensure your user has been added to
   `terraform.tfvars` and deployed
2. **Verify email match**: Your LFID email must exactly match the email in
   the Terraform configuration
3. **Role assignment**: Confirm your user has been assigned the correct role
   (e.g., "Limited Read Write")
4. **SSO configuration**: Contact the LF PyTorch infrastructure team if SSO
   login fails

### Role Capabilities

After logging in with SSO, your access will be determined by your assigned
role:

- **Limited Read Write Role**: Can view all monitoring data and create/edit
  dashboards, monitors, and incidents
- **Admin Role**: Full administrative access (reserved for infrastructure
  team)
- **Read Only Role**: View-only access to monitoring data
- **Standard Role**: Basic Datadog access with limited write permissions

[Back to top](#table-of-contents)

## Security Considerations

- **Principle of Least Privilege**: Only assign necessary permissions
- **Regular Review**: Periodically audit user access and roles
- **Disabled Accounts**: Use `disabled = true` instead of deleting users
  when access is temporarily revoked
- **External Users**: Consider using separate roles for
  contractors/external users

[Back to top](#table-of-contents)

## Troubleshooting

### Common Issues

1. **Permission not found errors:**
   - Check that permission names match exactly
   - Verify permissions exist in your Datadog org
   - Use `terraform plan` to see available permissions

2. **Role assignment failures:**
   - Ensure roles are created before assigning to users
   - Check that role IDs are correctly referenced

3. **User creation failures:**
   - Verify email addresses are valid
   - Check that users don't already exist in Datadog

### Getting Help

- Check Terraform logs: `TF_LOG=DEBUG terraform apply`
- Review Datadog provider documentation
- Contact the PyTorch infrastructure team

[Back to top](#table-of-contents)

## Contributing

### Development Workflow

1. **Create a feature branch** from `main`
2. **Make your changes** to the Terraform configuration
3. **Run MegaLinter locally** to validate all code quality requirements
4. **Fix any issues** identified by MegaLinter
5. **Test locally**: Run `terraform plan` to validate your changes
6. **Commit and push**: Push your branch to trigger GitHub Actions checks
7. **Submit a pull request** with a clear description of changes
8. **Address feedback**: Fix any issues identified by reviewers or
   MegaLinter
9. **Merge after approval**: Once approved and all checks pass, merge to
   main

### Pre-commit Requirements

Before committing code, ensure:

- [ ] Code passes MegaLinter validation (run locally)
- [ ] `terraform plan` runs successfully
- [ ] Changes are tested and documented
- [ ] All security requirements are met

### Automated Checks

All pull requests will automatically run **MegaLinter**, which includes:

- **Terraform Formatting** (`tofu fmt`): Ensures code follows formatting
  standards
- **Terraform Linting** (`tflint`): Validates best practices and catches
  common errors
- **Security Scanning**: Checks for security issues in the configuration
- **Documentation Validation**: Ensures README and comments are up to date
- **Plan Validation**: Confirms the configuration is valid and shows planned
  changes

Changes cannot be merged until all MegaLinter checks pass.

### MegaLinter Configuration

The repository uses MegaLinter's Terraform flavor, which includes:

- Multiple Terraform/OpenTofu validators
- Security scanners (Checkov, TFSec)
- Documentation linters
- General code quality tools

For detailed configuration, see `.mega-linter.yml` (if present) or the
default Terraform flavor settings.

[Back to top](#table-of-contents)
