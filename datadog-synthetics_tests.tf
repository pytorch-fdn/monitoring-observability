###############
# pytorch.org #
###############

resource "datadog_synthetics_test" "pytorch-org" {
  type      = "api"
  name      = "pytorch.org Check"
  message   = "Notify @slack-pytorch-infra-alerts pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:www"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://pytorch.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "Install PyTorch"
  }
}

####################
# docs.pytorch.org #
####################

resource "datadog_synthetics_test" "pytorch-docs" {
  type      = "api"
  name      = "docs.pytorch.org Check"
  message   = "Notify @slack-pytorch-infra-alerts docs.pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:docs"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://docs.pytorch.org/docs/stable/index.html"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "PyTorch documentation"
  }
}

resource "datadog_synthetics_test" "pytorch-docs-redirect" {
  type      = "api"
  name      = "pytorch.org/docs Redirect Check"
  message   = "Notify @slack-pytorch-infra-alerts docs.pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:docs"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://pytorch.org/docs"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "301"
  }
  assertion {
    type     = "header"
    property = "location"
    operator = "is"
    target   = "https://docs.pytorch.org/docs"
  }
  assertion {
    type     = "header"
    property = "server"
    operator = "is"
    target   = "nginx"
  }
}

############################
# download.pytorch.org CDN #
############################

resource "datadog_synthetics_test" "pytorch-download" {
  type      = "api"
  name      = "download.pytorch.org CDN Check"
  message   = "Notify @slack-pytorch-infra-alerts download.pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:download"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://download.pytorch.org/whl"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "pytorch"
  }
}

###################
# hud.pytorch.org #
###################

resource "datadog_synthetics_test" "pytorch-hud" {
  type      = "api"
  name      = "hud.pytorch.org Check"
  message   = "Notify @slack-pytorch-infra-alerts hud.pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:hud"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "pytorch/pytorch"
  }
}


#################################
# Github pytorch/pytorch ci:sev #
#################################

resource "datadog_synthetics_test" "pytorch-github-ci-sev" {
  type      = "api"
  name      = "Github PyTorch ci:sev Check"
  message   = "Notify @slack-pytorch-infra-alerts https://github.com/pytorch/pytorch/issues?q=state%3Aopen%20label%3A%22ci%3A%20sev%22 has an open ci:sev case"
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:github"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://github.com/pytorch/pytorch/issues?q=state%3Aopen%20label%3A%22ci%3A%20sev%22"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "No results"
  }
}

#########################
# landscape.pytorch.org #
#########################

resource "datadog_synthetics_test" "pytorch-landscape" {
  type      = "api"
  name      = "landscape.pytorch.org Check"
  message   = "Notify @slack-pytorch-infra-alerts landscape.pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:landscape"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://landscape.pytorch.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "landscape"
  }
}

###########
# Discuss #
###########

resource "datadog_synthetics_test" "pytorch-discuss" {
  type      = "api"
  name      = "discuss.pytorch.org Check"
  message   = "Notify @webhook-lf-incident-io. Follow https://linuxfoundation.atlassian.net/wiki/spaces/IT/pages/30416028/On-call+Common+Fixes how to fix the issue."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:discuss"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://discuss.pytorch.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "PyTorch Forums"
  }
}

###############
# Dev Discuss #
###############

resource "datadog_synthetics_test" "pytorch-dev-discuss" {
  type      = "api"
  name      = "dev-discuss.pytorch.org Check"
  message   = "Notify @slack-pytorch-infra-alerts dev-discuss.pytorch.org is failing its monitor."
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:dev-discuss"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 300
    retry {
      count    = 3
      interval = 300000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://dev-discuss.pytorch.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type     = "body"
    operator = "contains"
    target   = "PyTorch releases"
  }
}

##################
# GitHub Runners #
##################

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-lf" {
  type      = "api"
  name      = "GHA Runner Queue Check - Linux Foundation Runners"
  message   = <<EOT
Detected GitHub Runner Queue - Linux Foundation Runners has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-lf.js")
  }
}

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-amd" {
  type      = "api"
  name      = "GHA Runner Queue Check - AMD Runners"
  message   = <<EOT
Detected GitHub Runner Queue - AMD Runners has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-rocm.js")
  }
}

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-ibm" {
  type      = "api"
  name      = "GHA Runner Queue Check - IBM Runners"
  message   = <<EOT
Detected GitHub Runner Queue - IBM Runners has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-s390x.js")
  }
}

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-intel" {
  type      = "api"
  name      = "GHA Runner Queue Check - Intel Runners"
  message   = <<EOT
Detected GitHub Runner Queue - Intel Runners has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-intel.js")
  }
}

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-meta" {
  type      = "api"
  name      = "GHA Runner Queue Check - Meta Runners"
  message   = <<EOT
Detected GitHub Runner Queue - Meta Runners has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-meta.js")
  }
}

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-meta-h100" {
  type      = "api"
  name      = "GHA Runner Queue Check - Meta Runners - AWS H100"
  message   = <<EOT
Detected GitHub Runner Queue - Meta Runners - AWS H100 has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-meta-h100.js")
  }
}

resource "datadog_synthetics_test" "pytorch-gha-runners-queue-check-nvidia" {
  type      = "api"
  name      = "GHA Runner Queue Check - Nvidia Runners"
  message   = <<EOT
Detected GitHub Runner Queue - Nvidia Runners has jobs waiting
unusually long for runners.

{{{synthetics.attributes.result.failure.message}}}

Check https://hud.pytorch.org/metrics for more details.

@slack-pytorch-infra-alerts
EOT
  status    = "live"
  tags      = ["env:project", "project:pytorch", "service:gha-runners"]
  locations = ["aws:us-west-2"]
  options_list {
    tick_every = 900
    retry {
      count    = 3
      interval = 60000
    }
  }
  request_definition {
    method = "GET"
    url    = "https://hud.pytorch.org/api/clickhouse/queued_jobs_by_label?parameters=%7B%7D"
  }
  assertion {
    type = "javascript"
    code = file("scripts/check-long-queue-nvidia.js")
  }
}
