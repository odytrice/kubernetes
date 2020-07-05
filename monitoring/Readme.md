# Kubernetes Monitoring

This set of configruation deploys Prometheus which is a Time Series Database and Graphana

To begin you need to clone this repository

## 1. Configure Prometheus to Scrap Services
You can configure prometheus to collect metrics from services. These services need to have an endpoint where prometheus can collect metrics. To make this work simply go to `prometheus/configmap.yaml`. It will look like the following

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus
data:
  prometheus.yml: |
      global:
        scrape_interval:     15s # By default, scrape targets every 15 seconds.

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
          metrics_path: "/metrics-endpoint"
          static_configs:
          - targets: ['service.namespace.svc.cluster.local:8000']
```

## 2. Setup Graphana Credentials

In order to login to the Graphana Dashboard, you will need to setup the Username and Password. But these must be encoded in base64. To encode a user name and password and update the `secret.yaml`

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

You need to generate your own username and password using bash i.e. 

```bash 
echo -n "securePa55word" | base64
```

You might need to update the resource requests and limits

## 3. Change Domain in the Grafana Ingress

In the Grafana directory, you will need to edit the `ingress.yaml` and supply your domain name and tls certificate. This post assumes that you are using nginx and cert-manager. It will look something like this

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: grafana
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - grafana.example.com
    secretName: tls-grafana-example
  rules:
  - host: grafana.example.com
    http:
      paths:
      - backend:
          serviceName: grafana
          servicePort: 3000
```



You will need to change the "namespace" and "service" to correspond to the namespace and service of the for the service you want to collect metrics from and `/metrics-endpoint`

## 4. Installation
To Install, Simply run the following from the root of the downloaded repository

```bash
kubectl apply -k monitoring
```