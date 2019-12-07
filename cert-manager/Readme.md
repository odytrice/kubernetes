# Setup Cert Manager

Cert Manager allows you to manage SSL Certificates. It automatically handles renewals and what not after you setup a Cluster Issuer

## Installation

```bash
# Install Cert Manager
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml

# Create Namespace
kubectl create namespace cert-manager

# Disable Resource Validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Add Helm Chart and update Repo
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Cert-Manager Chart
# !! Make sure you are in cert-manager namespace
helm install cert-manager jetstack/cert-manager --version v0.9.1
```

## Setup LetsEncrypt Cluster Issuer

First, you create a file called `cluster-issuers.yaml` and then paste in the following code. make sure you replace the email placeholders with your own emails

```yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v2.api.letsencrypt.org/directory
    email: [your-email-goes-here]
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          class: nginx
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: [your-email-goes-here]
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

then simply run

```bash
kubectl apply -f cluster-issuers.yaml
```

## Setup SSL Certs for Ingress

To setup SSL simply use the annotation and the tls configuration below

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: usermanager
  annotations:
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod  # Specifies the Cluster Issuer to use
    kubernetes.io/ingress.class: nginx
spec:
  tls:
    - hosts:
      - domain.example.com
      secretName: tls-edelwiess-usermanager  # Secret name is used to dynamically generate the secret
  rules:
  - host: domain.example.com
    http:
      paths:
      - backend:
          serviceName: web
          servicePort: 80
```