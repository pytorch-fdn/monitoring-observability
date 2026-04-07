# SPDX-FileCopyrightText: 2025 The Linux Foundation
#
# SPDX-License-Identifier: Apache-2.0

##############
# Dashboards #
##############

resource "datadog_dashboard" "ebs_volumes_dashboard" {
  title       = "AWS EBS Stale Volumes Dashboard"
  description = "Monitors EBS volumes in available (unattached) state to identify unused volumes incurring costs."
  layout_type = "ordered"

  widget {
    group_definition {
      title       = "Stale EBS Volumes Overview"
      layout_type = "ordered"

      widget {
        query_value_definition {
          title       = "Available (Unattached) EBS Volumes"
          title_size  = 16
          title_align = "left"
          request {
            formula {
              formula_expression = "query1"
            }
            query {
              metric_query {
                name        = "query1"
                data_source = "metrics"
                query       = "count:aws.ebs.volume_idle_time{status:available}"
                aggregator  = "last"
              }
            }
          }
          precision = 0
        }
      }

      widget {
        toplist_definition {
          title       = "Available EBS Volumes by Idle Time (Last Month)"
          title_size  = 16
          title_align = "left"
          request {
            formula {
              formula_expression = "query1"
            }
            query {
              metric_query {
                name        = "query1"
                data_source = "metrics"
                query       = "max:aws.ebs.volume_idle_time{status:available} by {name,volumeid}"
                aggregator  = "avg"
              }
            }
          }
        }
      }

      widget {
        timeseries_definition {
          title       = "EBS Volume Idle Time (Available Volumes)"
          title_size  = 16
          title_align = "left"
          show_legend = true
          request {
            formula {
              formula_expression = "query1"
            }
            query {
              metric_query {
                name        = "query1"
                data_source = "metrics"
                query       = "max:aws.ebs.volume_idle_time{status:available} by {volumeid}"
              }
            }
            display_type = "line"
          }
        }
      }
    }
  }

  widget {
    group_definition {
      title       = "Monitor Status"
      layout_type = "ordered"

      widget {
        manage_status_definition {
          title               = "EBS Volume Monitors"
          title_size          = 16
          title_align         = "left"
          query               = "Stale EBS Volume"
          display_format      = "countsAndList"
          color_preference    = "text"
          hide_zero_counts    = true
          show_last_triggered = true
          sort                = "status,asc"
          summary_type        = "monitors"
        }
      }
    }
  }
}

resource "datadog_dashboard" "status_dashboard" {
  title       = "PyTorch Services Status Dashboard"
  description = "Shows the current status of PyTorch Services."
  layout_type = "free"

  widget {
    manage_status_definition {
      color_preference    = "text"
      display_format      = "countsAndList"
      hide_zero_counts    = true
      query               = ""
      show_last_triggered = false
      sort                = "status,asc"
      summary_type        = "monitors"
      title               = "PyTorch Service Monitors"
      title_size          = 16
      title_align         = "left"
    }
    widget_layout {
      height = 100
      width  = 80
      x      = 0
      y      = 0
    }
  }
}
