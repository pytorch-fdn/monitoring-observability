#####################
# Lambda Autoscaler #
#####################

resource "datadog_monitor" "ci_retry_deadletter" {
  name    = "ALI AutoScaler Dead Letter Queue High Number Of Messages"
  message = <<-MSG
    An unusually high number of messages is in the `ghci-lf-queued-builds-dead-letter` queue. This may indicate a potential outage with the project's autoscaler.
    Verify that system is able to scale up EC2 instances by checking logs.

    @webhook-lf-incident-io
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
  name     = "Queue **{{queuename.name}}** has a high number of visible messages"
  message  = <<-MSG
    The number of visible messages in `{{queuename.name}}` is outside of the typical range.
  MSG
  priority = 5

  type  = "query alert"
  query = <<-QUERY
    avg(last_1w):
    anomalies(
      avg:aws.sqs.approximate_number_of_messages_visible{project:pytorch/pytorch} by {queuename,region},
      'basic', 2, direction='both', interval=3600, alert_window='last_1d', count_default_zero='true'
    ) >= 1
  QUERY

  include_tags        = true
  on_missing_data     = "default"
  require_full_window = false

  monitor_threshold_windows {
    recovery_window = "last_15m"
    trigger_window  = "last_1d"
  }

  monitor_thresholds {
    critical          = "1"
    critical_recovery = "0"
    warning           = "0.9"
  }
}
