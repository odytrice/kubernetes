# Kubeflow Notebooks

This directory contains the Kustomize configuration to install Kubeflow Notebooks.

### Installation

To install the Kubeflow Notebooks components, apply the Kustomize configuration:

```bash
kubectl apply -k .
```

This will install the Notebook Controller and the Jupyter Web App.

### Accessing Notebooks

After installation, you can access the Jupyter Web App through the Kubeflow Central Dashboard.
