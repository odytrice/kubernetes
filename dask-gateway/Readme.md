# Dask Cluster Setup

## Installation

```bash
helm upgrade --install --namespace dask-gateway --version 0.8.0 --values config.yaml dask-gateway daskgateway/dask-gateway
```

## Expose Dask Cluster

```bash
kubectl apply -f ingress.yaml
```