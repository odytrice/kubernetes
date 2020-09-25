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
# Configuration Details
# https://docs.gitlab.com/charts/charts/globals.html
global:
  edition: ce
  hosts:
    domain: gitlab.kubebridge.com

  shell:
    port: 2222

  pod:
    labels:
      environment: prod

  deployment:
    annotations:
      environment: prod

  service:
    annotations:
      environment: prod

  ingress:
    class: nginx
    configureCertmanager: false
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      acme.cert-manager.io/http01-edit-in-place: "true"


certmanager:
  install: false

nginx-ingress:
  enabled: false

gitlab:
  webservice:
    ingress:
      tls:
        secretName: gitlab-webservice-tls
  gitaly:
    persistence:
      size: 2Gi

registry:
  ingress:
    tls:
      secretName: gitlab-registry-tls

postgresql:
  persistence:
    size: 2Gi
minio:
  ingress:
    tls:
      secretName: gitlab-minio-tls
  persistence:
    size: 2Gi
redis:
  persistence:
    size: 2Gi

prometheus:
  alertmanager:
    enabled: false
    persistentVolume:
      enabled: false
      size: 2Gi
  pushgateway:
    enabled: false
    persistentVolume:
      enabled: false
      size: 2Gi
  server:
    persistentVolume:
      enabled: true
      size: 2Gi
```

To retrieve the password you use

```bash
# <name> should be the name of the gitlab installation i.e. gitlab
kubectl get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode

```