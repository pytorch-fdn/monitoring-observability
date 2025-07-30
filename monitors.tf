#####################
# Lambda Autoscaler #
#####################

resource "datadog_monitor" "ci_retry_deadletter" {
  name    = "ALI AutoScaler Dead Letter Queue High Number Of Messages"
  message = <<-MSG
    An unusually high number of messages is in the `ghci-lf-queued-builds-dead-letter` queue. This may indicate a potential outage with the project's autoscaler.
    Verify that system is able to scale up EC2 instances by checking logs.

    @webhook-lf-incident-io
    @slack-PyTorch-pytorch-infra-alerts
    @slack-Linux_Foundation-pytorch-alerts
  MSG

  type  = "query alert"
  query = <<-QUERY
    sum(last_5m):max:aws.sqs.number_of_messages_sent{queuename:ghci-lf-queued-builds-dead-letter}.as_count() > 5000
  QUERY

  monitor_thresholds {
    warning  = "1000"
    critical = "5000"
  }

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
}


resource "datadog_monitor" "all_queues_anomaly" {
  evaluation_delay    = 900
  require_full_window = false
  monitor_thresholds {
    critical          = 1
    critical_recovery = 0
    warning           = 0.9
  }
  monitor_threshold_windows {
    recovery_window = "last_15m"
    trigger_window  = "last_1d"
  }
  name     = "Queue **{{queuename.name}}** has a high number of visible messages"
  type     = "query alert"
  priority = 5
  query    = <<EOT
avg(last_1w):
anomalies(
  avg:aws.sqs.approximate_number_of_messages_visible{project:pytorch/pytorch} by {queuename,region},
  'basic', 2, direction='both', interval=3600, alert_window='last_1d', count_default_zero='true'
) >= 1
EOT
  message  = <<EOT
The number of visible messages in `{{queuename.name}}` is outside of the typical range.
@slack-PyTorch-pytorch-infra-alerts
@slack-Linux_Foundation-pytorch-alerts
@webhook-lf-incident-io
EOT
}

resource "datadog_monitor" "ALI_ValidationException_Detected" {
  include_tags        = false
  require_full_window = false
  monitor_thresholds {
    critical = 0
  }
  name    = "ALI ValidationException Detected"
  type    = "event-v2 alert"
  query   = <<EOT
events("source:amazon_sns @title:\"ALI ValidationException Detected\"").rollup("count").last("5m") > 0
EOT
  message = <<EOT
# ValidationException

We've detected that a ValidationException has happened in the ALI. This could
mean the ALI is having issues scaling up runners. Perhaps test-infra release
was recently updated which may affect this.

## Action

Review scale-up lambda logs in CloudWatch to triage issue and take any
necessary action. Revert test-infra release to last known working version if
necessary.

@slack-PyTorch-pytorch-infra-alerts
@slack-Linux_Foundation-pytorch-alerts
@webhook-lf-incident-io
EOT
}

resource "datadog_monitor" "GitHub_API_usage_unusually_high" {
  include_tags        = false
  require_full_window = false
  monitor_thresholds {
    critical = 0
  }
  name    = "GitHub API usage unusually high"
  type    = "event-v2 alert"
  query   = <<EOT
events("source:amazon_sns @title:\"GitHub API usage unusually high\"").rollup("count").last("5m") > 0
EOT
  message = <<EOT
# GitHub API usage is unusually high

We've detected that the GitHub API rate limit usage is higher than usual. This could be an indication of a problem in the ALI system causing higher than expected API calls.

## Action

Review the rate limit metrics as well as API call count from the ALI for each API call to see if anything unusual is occurring.

@slack-PyTorch-pytorch-infra-alerts
@slack-Linux_Foundation-pytorch-alerts
@webhook-lf-incident-io
EOT
}
