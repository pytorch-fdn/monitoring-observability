# SPDX-FileCopyrightText: 2025 2025 The Linux Foundation
#
# SPDX-License-Identifier: Apache-2.0

##############
# Dashboards #
##############

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
