data "aws_caller_identity" "pytorch" {}
# Datadog integration for AWS
# This integration allows Datadog to monitor AWS resources and services.
resource "datadog_integration_aws_account" "pytorch" {
  aws_account_id = data.aws_caller_identity.pytorch.account_id
  aws_partition  = "aws"
  aws_regions {
    include_all = true
  }
  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }
  logs_config {
    lambda_forwarder {}
  }
  metrics_config {
    namespace_filters {
      exclude_only = [
        "AWS/SQS",
        "AWS/ElasticMapReduce",
      ]
    }
  }
  resources_config {}
  traces_config {
    xray_services {}
  }
}
# Datadog integration for Slack
resource "datadog_integration_slack_channel" "pytorch-infra-alerts" {
  account_name = "PyTorch"
  channel_name = "#pytorch-infra-alerts"

  display {
    message      = true
    notified     = true
    snapshot     = true
    tags         = true
    mute_buttons = true
  }
}
