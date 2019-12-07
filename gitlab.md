# Gitlab Installation using Helm 3

For more details check here https://docs.gitlab.com/charts/installation/deployment.html

```bash
#Add Gitlab Chart Repo
helm repo add gitlab https://charts.gitlab.io/

# Update the Repo
helm repo update

# Install your wildcard cert
kubectl create secret tls dev-io-tls --cert=tls-dev-io.crt --key=tls-dev-io.key

# Install Gitlab using helm 3
helm install gitlab gitlab/gitlab -f HELM_OPTIONS_YAML_FILE

# Install Gitlab using helm 2
helm2 install gitlab/gitlab --name gitlab -f ".\gitlab.yaml"
```

Here is a Sample Yaml Configuration

```yaml
global:
  hosts:
    domain: dev.io
    externalIP: 172.17.151.181
  ingress:
    configureCertmanager: false
    tls:
      secretName: dev-io-tls
certmanager:
  install: false

gitlab:
  gitaly:
    persistence:
      size: 10Gi
postgresql:
  persistence:
    size: 8Gi
minio:
  persistence:
    size: 10Gi
redis:
  persistence:
    size: 5Gi
```