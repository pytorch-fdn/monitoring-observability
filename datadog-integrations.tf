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
    collect_cloudwatch_alarms = true
    collect_custom_metrics    = true

  }
  resources_config {
    cloud_security_posture_management_collection = true
  }
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

# Create a new Datadog webhook

resource "datadog_webhook" "lf-incident-io" {
  name      = "lf-incident-io"
  url       = "https://api.incident.io/v2/alert_events/datadog/01JKTRSFTE6H2SR4AFM4VGWZFN"
  encode_as = "json"

  custom_headers = jsonencode({ "Authorization" = "Bearer ${var.incident_io_bearer}  " })
  payload        = <<-EOT
{
  "alert_transition": "$ALERT_TRANSITION",
  "deduplication_key": "$AGGREG_KEY-$ALERT_CYCLE_KEY",
  "title": "$EVENT_TITLE",
  "description": "$EVENT_MSG",
  "source_url": "$LINK",
  "metadata": {
    "id": "$ID",
    "alert_metric": "$ALERT_METRIC",
    "alert_query": "$ALERT_QUERY",
    "alert_scope": "$ALERT_SCOPE",
    "alert_status": "$ALERT_STATUS",
    "alert_title": "$ALERT_TITLE",
    "alert_type": "$ALERT_TYPE",
    "alert_url": "$LINK",
    "alert_priority": "$ALERT_PRIORITY",
    "date": "$DATE",
    "event_type": "$EVENT_TYPE",
    "hostname": "$HOSTNAME",
    "last_updated": "$LAST_UPDATED",
    "logs_sample": $LOGS_SAMPLE,
    "org": {
      "id": "$ORG_ID",
      "name": "$ORG_NAME"
    },
    "snapshot_url": "$SNAPSHOT",
    "tags": "$TAGS"
  }
}
EOT
}
