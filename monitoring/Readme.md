# Kubernetes Monitoring

This set of configruation deploys Prometheus which is a Time Series Database and Graphana

To begin, you need to clone this repository and copy out the `monitoring` directory. You make the necessary updates to the configuration files after which you install it using `kubectl apply`

## 1. Configure Prometheus to Scrap Services
You can configure prometheus to collect metrics from services. These services need to have an endpoint where prometheus can collect metrics. To make this work edit the `prometheus/configmap.yaml` file.

It will look like the following:

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus
data:
  prometheus.yml: |
      global:
        scrape_interval: 15s # By default, scrape targets every 15 seconds.

        # Attach these labels to any time series or alerts when communicating with
        # external systems (federation, remote storage, Alertmanager).
        external_labels:
          monitor: 'intervals'

      # A scrape configuration containing exactly one endpoint to scrape:
      # Here it's Prometheus itself.
      scrape_configs:
        # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
        - job_name: 'prometheus'
          static_configs:
            - targets: ['localhost:9090']

        # This sample job is for a service inside the cluster and the service
        # exposes a /metrics-text endpoint
        - job_name: 'application'
          metrics_path: "/metrics-endpoint" # This is for custom metrics endpoint, the default is /metrics
          static_configs:
          - targets: ['<service>.<namespace>.svc.cluster.local:8000']
```

You will need to change the "namespace" and "service" to correspond to the namespace and service of the for the service you want to collect metrics from.

See the [Traefik Example](#traefik-example) below for an example on how to modify this file

### Traefik Example

In order to configure Prometheus to scrape logs from Traefik, we need to register Traefik as a scrape target for Prometheus

We do this by modifying the `prometheus/configmap.yaml` and adding the following under the `scrape_configs:` section

```yaml
- job_name: 'traefik'
  static_configs:
  - targets: ['traefik.kube-system.svc.cluster.local:8080']
```

Now we need to configure Traefik to expose the Metrics. We do this by adding the metrics config to the Toml config map (e.g. `traefik/traefik-config-map.yaml`) as shown below:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: traefik-conf
data:
  traefik.toml: |
    ...
    # These three lines setup a traefik entrypoint to 8080
    [entryPoints]
      [entryPoints.metrics]
        address = ":8080"
    ...
    # These three lines tell traefik to expose the promethus metrics via the metrics entrypoint
    [metrics]
    [metrics.prometheus]
      entryPoint = "metrics"
```

After this we can now move on to setting up grafana

## 2. Setup Graphana Credentials

In order to login to the Graphana Dashboard, you will need to setup the Username and Password. But these must be encoded in base64.

In order to encode either the username or the password, You simply execute the following using bash i.e.

```bash
echo -n "securePa55word" | base64
```

After you have encoded the username and password respectively, you then update the `grafana/secret.yaml` file.

**NOTE you need to change this before installing the Application**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: grafana
type: Opaque
data:
  # NOTE: CHANGE THESE VALUES BEFORE DEPLOYING TO PRODUCTION
  admin-user: YWRtaW4=  #admin
  admin-password: cGFzc3dvcmQ= #password
```

You might need to update the resource requests and limits

## 3. Change Domain in the Grafana Ingress

In the Grafana directory, you will need to edit the `grafana/ingress.yaml` and supply your domain name and tls certificate. This post assumes that you are using Traefik Ingress controller. It will look something like this

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana
  annotations:
    # If you are using nginx ingress controller you should change it here
    kubernetes.io/ingress.class: traefik
spec:
  tls:
  - hosts:
    - grafana.example.com
  rules:
  - host: grafana.example.com
    http:
      paths:
      - backend:
          serviceName: grafana
          servicePort: 3000
```


## 4. Installation
To Install, Simply run the following from the root of the downloaded repository

```bash
kubectl apply -k monitoring
```
