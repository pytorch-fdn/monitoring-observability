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
- [Table of Contents](#table-of-contents)
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
    roles    = [datadog_role.roles["custom-read-write"].id]
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
    roles    = [datadog_role.roles["custom-read-write"].id]
    disabled = false
  },
  "john-doe" = {
    email    = "john.doe@contractor.com"
    roles    = [datadog_role.roles["custom-read-write"].id]
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
    roles    = [datadog_role.roles["custom-read-write"].id]
    disabled = false
  },
  "team-member-2" = {
    email    = "member2@example.com" 
    roles    = [datadog_role.roles["custom-read-write"].id]
    disabled = false
  },
  "contractor" = {
    email    = "contractor@external.com"
    roles    = [datadog_role.roles["custom-read-write"].id]
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

These lightweight API checks verify availability and basic correctness for
public PyTorch properties every 5 minutes:

- pytorch.org
  - GET <https://pytorch.org> → status 200 and body contains
    "Install PyTorch"
  - Alerts: @slack-pytorch-infra-alerts

- docs.pytorch.org
  - GET <https://docs.pytorch.org/docs/stable/index.html> → status 200 and
    body contains "PyTorch documentation"
  - Alerts: @slack-pytorch-infra-alerts

- pytorch.org/docs redirect
  - GET <https://pytorch.org/docs> → status 301; headers:
    - location is <https://docs.pytorch.org/docs>
    - server is nginx
  - Alerts: @slack-pytorch-infra-alerts

- download.pytorch.org (CDN index)
  - GET <https://download.pytorch.org/whl> → status 200 and body contains
    "pytorch"
  - Alerts: @slack-pytorch-infra-alerts

- hud.pytorch.org
  - GET <https://hud.pytorch.org> → status 200 and body contains
    "pytorch/pytorch"
  - Alerts: @slack-pytorch-infra-alerts

- landscape.pytorch.org
  - GET <https://landscape.pytorch.org> → status 200 and body contains
    "landscape"
  - Alerts: @slack-pytorch-infra-alerts

- discuss.pytorch.org
  - GET <https://discuss.pytorch.org> → status 200 and body contains
    "PyTorch Forums"
  - Alerts: @webhook-lf-incident-io (follow LF runbook)

- dev-discuss.pytorch.org
  - GET <https://dev-discuss.pytorch.org> → status 200 and body contains
    "PyTorch releases"
  - Alerts: @slack-pytorch-infra-alerts

Cadence: tick_every = 300s; retries: 3 attempts, 300,000 ms interval.

### GitHub ci-sev issues check

Watches for open issues labeled "ci: sev" in pytorch/pytorch. Fails if any
are found.

- GET <https://github.com/pytorch/pytorch/issues?q=state%3Aopen%20label%3A%22ci%3A%20sev%22>
- Expect status 200 and body contains "No results"
- Alerts: @slack-pytorch-infra-alerts
- Cadence: tick_every = 300s

### Synthetics queue checks (scripts/)

These API tests detect long GitHub Actions runner queues and alert Slack.

How it works:

- Each test calls the HUD endpoint
  <https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D>
- The script expects HTTP 200, parses JSON, and filters by machine_type
  pattern
- If any item exceeds a per-vendor queue time threshold, the test fails
- On failure, the script logs a human message which is included in the
  Datadog alert and sent to Slack

Scripts and thresholds:

- [check-long-queue-lf.js](./scripts/check-long-queue-lf.js)
  - Filter: machine_type startsWith 'lf.'
  - Threshold: > 10,800s (3h)

- [check-long-queue-nvidia.js](./scripts/check-long-queue-nvidia.js)
  - Filter: machine_type includes '.dgx.'
  - Threshold: > 10,800s (3h)

- [check-long-queue-rocm.js](./scripts/check-long-queue-rocm.js)
  - Filter: machine_type includes '.rocm.'
  - Threshold: > 14,400s (4h)

- [check-long-queue-s390x.js](./scripts/check-long-queue-s390x.js)
  - Filter: machine_type includes '.s390x'
  - Threshold: > 7,200s (2h)

- [check-long-queue-intel.js](./scripts/check-long-queue-intel.js)
  - Filter: machine_type includes '.idc.'
  - Threshold: > 10,800s (3h)

- [check-long-queue-meta-h100.js](./scripts/check-long-queue-meta-h100.js)
  - Filter: machine_type equals 'linux.aws.h100'
  - Threshold: > 21,600s (6h)

- [check-long-queue-meta.js](./scripts/check-long-queue-meta.js)
  - Filter: excludes '.dgx.', '.rocm.', '.s390x', '^lf\\.', '^linux.aws.h100'
  - Threshold: > 10,800s (3h)

Example failure message (from script stderr):

```text
High queue detected for machine types containing .s390x: linux.s390x (7300s)
```

### Datadog monitors (ALI/GitHub API)

Event and metric-based monitors supporting autoscaler and GitHub API health:

- ALI AutoScaler Dead Letter Queue High Number Of Messages
  - Query: sum(last_5m):max:aws.sqs.number_of_messages_sent{
    queuename:ghci-lf-queued-builds-dead-letter}.as_count() > 5000
  - Thresholds: warning 1000; critical 5000
  - Action: check scale-up logs; alerts to @webhook-lf-incident-io,
    @slack-PyTorch-pytorch-infra-alerts, @slack-Linux_Foundation-pytorch-alerts

- ALI ValidationException Detected
  - Type: event-v2 alert on SNS event with title "ALI ValidationException
    Detected" in last 5 minutes
  - Critical when count > 0
  - Action: review scale-up Lambda logs; possibly revert test-infra release
  - Alerts: @slack-PyTorch-pytorch-infra-alerts,
    @slack-Linux_Foundation-pytorch-alerts, @webhook-lf-incident-io

- GitHub API usage unusually high
  - Type: event-v2 alert on SNS event with title "GitHub API usage unusually
    high" in last 5 minutes
  - Critical when count > 0
  - Action: review ALI rate limit metrics and API call counts
  - Alerts: @slack-PyTorch-pytorch-infra-alerts,
    @slack-Linux_Foundation-pytorch-alerts, @webhook-lf-incident-io

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
