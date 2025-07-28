data "aws_caller_identity" "pytorch" {}
# Datadog integration for AWS
# This integration allows Datadog to monitor AWS resources and services.
resource "datadog_integration_aws" "pytorch" {
  account_id = data.aws_caller_identity.pytorch.account_id
  role_name  = "DatadogIntegrationRole"
}
# Datadog integration for Slack
resource "datadog_integration_slack_channel" "pytorch-infra-alerts" {
  account_name = "PyTorch"
  channel_name = "#pytorch-infra-alerts"

  display {
    message  = true
    notified = true
    snapshot = true
    tags     = true
  }
}