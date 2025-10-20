# Install Traefik Ingress Controller

Traefik can be installed in Kubernetes using the Helm chart from https://github.com/traefik/traefik-helm-chart.

Ensure that the following requirements are met:

- Kubernetes 1.22+
- Helm version 3.9+ is installed

Add Traefik Labs chart repository to Helm:

```bash
helm repo add traefik https://traefik.github.io/charts

```

You can update the chart repository by running:

```bash
helm repo update
```
And install it with the Helm command line:

```bash
kubectl create namespace ingress-traefik
helm install traefik traefik/traefik --namespace ingress-traefik
```

## Bare Metal

If you don't have a load balancer.

Here is the full documentation for the `values.yaml`

https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml



```yaml
# docs https://github.com/traefik/traefik-helm-chart/blob/master/traefik/values.yaml
deployment:
  # DaemonSet ensures that there is only 1 pod per node
  kind: DaemonSet

# Specifying HostPort directly opens up the port on the Node itself
ports:
  web:
    port: 80
    hostPort: 80
  websecure:
    port: 443
    hostPort: 443
  metrics:
    port: 9100
    expose:
      default: true
```

To see what it generates you can simply run

```bash
## Generate the Template to see what helm chart is doing
helm template traefik traefik/traefik --namespace ingress-traefik --values ./ingress/traefik/bare-metal.yaml

## Install Helm Chart
helm install traefik traefik/traefik --namespace ingress-traefik --values ./ingress/traefik/bare-metal.yaml
```

## HTTPS Redirect Middleware

To automatically redirect HTTP traffic to HTTPS, you can use the included middleware configuration.

### Apply the Middleware

```bash
kubectl apply -f ./ingress/traefik/https-redirect.yaml
```

This creates a Traefik middleware named `https-redirect` that permanently redirects all HTTP requests to HTTPS.

### Using the Middleware in an Ingress

To use this middleware with your ingress routes, add the middleware annotation:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    traefik.ingress.kubernetes.io/router.middlewares: default-https-redirect@kubernetescrd
spec:
  # your ingress rules here
```

**Note:** The middleware reference format is `<namespace>-<middleware-name>@kubernetescrd`. If you deployed the middleware in a different namespace, adjust the annotation accordingly.