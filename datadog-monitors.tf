# SPDX-FileCopyrightText: 2025 The Linux Foundation
#
# SPDX-License-Identifier: Apache-2.0

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
    @slack-Linux_Foundation-pytorch-infra
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
@slack-Linux_Foundation-pytorch-infra
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
@slack-Linux_Foundation-pytorch-infra
@webhook-lf-incident-io
EOT
}

###############################
# download.pytorch.org 499s   #
###############################

resource "datadog_monitor" "download_pytorch_whl_499_spike" {
  name    = "download.pytorch.org 499 spike"
  type    = "log alert"
  query   = <<-EOT
    logs("service:cloudflare_pytorch_org @EdgeRequestHost:download*.pytorch.org @ClientRequestPath:/whl* @EdgeResponseStatus:499").rollup("count").last("1m") > 50
  EOT
  message = <<-MSG
    More than fifty CloudFront 499 responses per minute are being served for download.pytorch.org /whl paths.

    @slack-PyTorch-pytorch-infra-alerts
  MSG

  include_tags        = true
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  notify_audit      = false
  notify_no_data    = false
  renotify_interval = 0
}
