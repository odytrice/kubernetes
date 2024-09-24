# Installing Prometheus

There are two helm charts to deploy and run prometheus

- Prometheus Community Chart
- Prometheus Operator

## Prerequisites

First you create the monitoring Namespace

```bash
kubectl create namespace monitoring
```

And then You add the Prometheus Community Repo

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## Prometheus Community Chart

To see what you can customize. Simply run

```bash
helm show values prometheus-community/prometheus > values.yaml
```

This is useful if you want to configure scrape configuration directly e.g. There are a ton of customization options including setting alerts for AlertManager as well

```yaml
serverFiles:
  prometheus.yml:
    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets:
            - localhost:9090
```

And then you simply install it using

```bash
helm install prometheus prometheus-community/prometheus --namespace monitoring
```

You can then check the state using

```bash
kubectl get pods -n monitoring
```

To uninstall, you simply do

```bash
helm uninstall prometheus
```


## Prometheus Operator

This is a bit more complicated. See the video below for more information

<iframe width="560" height="315" src="https://www.youtube.com/embed/6xmWr7p5TE0?si=urFNYPQ_7Z_52fXF" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

To see what you can customize. Simply run

```bash
helm show values prometheus-community/kube-prometheus-stack > defaults.yaml
```

Install using

```bash
# Install with preset values
helm install prometheus prometheus-community/kube-prometheus-stack -namespace monitoring -f values.yaml
```

You can listen to services using a service monitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: api-service-monitor
  labels:
    release: prometheus     # Used by Prometheus to locate which service monitors to track
    app: prometheus         # Not Sure
spec:
  jobLabel: job                   # Label on the Service whose value will be the name of the job (e.g. job: api-service)
  endpoints:
  - interval: 30s               # Scrape Interval
    port: web                   # Scrape Port - Default: 80
    path: swagger-stats/metrics # Scrape Path - Default: /metrics
  selector:
    matchLabels:
      app: service-api        # label for the service that it should scrape
```

For Alerting we can add a prometheus rule

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: api-rules
  labels:
    release: prometheus     # Used by Prometheus to locate which service monitors to track
spec:
  groups:
  - name: api
    rules:
    - alert: down
      expr: up == 0
      for: 0m
      labels:
        severity: critical
      annotations:
        summary: Prometheus target missing {{$labels.instance}}
```

for Alert Manager config we can create the following

```yaml
apiVersion: monitoring.coreos.com/v1
kind: AlertmanagerConfig
metadata:
  name: alert-config
  labels:
    release: prometheus     # Used by Prometheus to locate which service monitors to track
spec:
  route:
    groupBy: ["severity"]
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
    receiver: "webhook"
  receivers:
  - name: "webhook"
    webhookConfigs:
    - url: "http://example.com"
```