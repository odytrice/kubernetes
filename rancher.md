# Rancher Installation

## Prerequisites
In order to install Rancher in your cluster, Your cluster needs to have the following:

1. Storage Configured (e.g. using [NFS Storage Provisioner](nfs-storage/Readme.md))
2. Ingress Controller (e.g. using [Nginx](ingress/nginx.md) or [Traefik](ingress/traefik.md))
3. Cert-Manager (see [Setup Cert Manager](cert-manager/Readme.md))

## Steps:
  1. Setup Helm
  2. Install Rancher

### 1. Setup Helm
Just download the binary for your OS and add it to your system Path variable
https://github.com/helm/helm/releases

The full instruction for installing Helm is available here https://v3.helm.sh/docs/intro/install/

### 2. Install Rancher
Add the Racncher Helm Chart Repository

```bash
# Add Chart

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
```

Create the rancher namespace

```
kubectl create namespace rancher
```

You can install rancher in one of two ways
1. Using LetsEncrypt to generate SSL Certificates
2. Using your own SSL Certificate

#### 1. Using LetsEncrypt
```bash
# Install Rancher using LetsEncrypt
helm install rancher rancher-latest/rancher --namespace rancher --set hostname=rancher.hostname.com --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=me@example.org
```

#### 2. Using your own Certificates
```bash
# Install Rancher using Your Own Certs
# Make sure the tls Cert is configured in rancher namespace
kubectl create secret tls tls-rancher-ingress --cert=tls-dev-io.crt --key=tls-dev-io.key --namespace rancher

# Install using the Certs
helm install rancher rancher-latest/rancher --namespace rancher --set hostname=rancher.hostname.com --set ingress.tls.source=tls-rancher-ingress
```