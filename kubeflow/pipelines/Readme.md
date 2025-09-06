# Kubeflow Pipelines

This directory contains the Kustomize configuration to install Kubeflow Pipelines.

### Installation

1. **Apply the Kustomize configuration**:

   ```bash
   kubectl apply -k .
   ```

2. **Wait for CRDs to be Established**:
   Before proceeding, wait for the `Application` Custom Resource Definition (CRD) to be established in the cluster.

   ```bash
   kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
   ```

### Accessing the UI

Once the deployment is complete, you can access the Kubeflow Pipelines UI by port-forwarding the `ml-pipeline-ui` service:

```bash
kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80
```

You can then open your web browser and navigate to `http://localhost:8080` to view the Pipelines UI.
