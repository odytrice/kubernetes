# Kubeflow Dashboard

This directory contains the Kustomize configuration to install the Kubeflow Central Dashboard.

### Installation

To install the Kubeflow Central Dashboard, apply the Kustomize configuration:

```bash
kubectl apply -k .
```

### Accessing the Dashboard

Once the installation is complete, you can access the Central Dashboard by port-forwarding the `istio-ingressgateway` service:

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

You can then open your web browser and navigate to `http://localhost:8080`.
