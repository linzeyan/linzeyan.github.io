---
title: "Prometheus relabeling and linux metrics"
date: 2024-05-14T13:49:00+08:00
menu:
  sidebar:
    name: Prometheus relabeling and linux metrics
    identifier: prometheus-relabeling-linux-metrics
    weight: 10
tags: ["Prometheus", "URL"]
categories: ["Prometheus", "URL"]
---

# Prometheus relabeling and linux metrics

_Adding new label_

```yaml
- target_label: "foo"
  replacement: "bar"
```

_metrics_

- rkB/s:
  `rate(node_disk_read_bytes_total[*])`
  Unit: bytes per second
- wkB/s:
  `rate(node_disk_written_bytes_total[*])`
  Unit: bytes per second

## Reference

- [How to use relabeling in Prometheus and VictoriaMetrics](https://valyala.medium.com/how-to-use-relabeling-in-prometheus-and-victoriametrics-8b90fc22c4b2)
- [Interpreting Prometheus metrics for Linux disk I/O utilization](https://brian-candler.medium.com/interpreting-prometheus-metrics-for-linux-disk-i-o-utilization-4db53dfedcfc)
