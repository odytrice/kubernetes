# Setup Cert Manager

Cert Manager allows you to manage SSL Certificates. It automatically handles renewals and what not after you setup a Cluster Issuer

## Installation

```bash
# Create Namespace
kubectl create namespace cert-manager

# Disable Resource Validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Install Cert Manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager.crds.yaml

# Add Helm Chart and update Repo
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Cert-Manager Chart
# !! Make sure you are in cert-manager namespace
helm install cert-manager jetstack/cert-manager --version v0.15.1 --namespace cert-manager
```

## Setup LetsEncrypt Cluster Issuer

First, you create a file called `cluster-issuers.yaml` and then paste in the following code.

**NOTE**❗❗ Make sure you replace the email placeholders **user@example.com** with your own emails

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: user@example.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    # An empty 'selector' means that this solver matches all domains
    - selector: {}
      http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: user@example.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    # An empty 'selector' means that this solver matches all domains
    - selector: {}
      http01:
        ingress:
          class: nginx
```

then simply run

```bash
kubectl apply -f cluster-issuers.yaml
```

You can confirm that it ran successfully but running

```bash
kubectl get clusterissuers
```
and you should get the following output
```
NAME                  READY   AGE
letsencrypt-prod      True    58s
letsencrypt-staging   True    58s
```

## Deploying SSL Certificates for Ingress

To setup an SSL Certificate simply use the annotation and the tls configuration below

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: usermanager
  annotations:
    certmanager.io/cluster-issuer: letsencrypt-prod    # Specifies the Cluster Issuer to use
    acme.cert-manager.io/http01-edit-in-place: "true"  # Tells Cert-Manager to override this ingress temporarily
    kubernetes.io/ingress.class: nginx
spec:
  tls:
    - hosts:
      - domain.example.com
      secretName: tls-domain-example  # Secret name is used to dynamically generate the secret
  rules:
  - host: domain.example.com
    http:
      paths:
      - backend:
          serviceName: web
          servicePort: 80
```
