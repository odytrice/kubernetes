# Kubeflow Components

This document provides instructions for installing individual Kubeflow components.

## Table of Contents
- [Unified Installation (Kustomize)](#unified-installation-kustomize)
- [Component Details](#component-details)
  - [Istio](#istio)
  - [Kubeflow Dashboard](#kubeflow-dashboard)
  - [Kubeflow Notebooks](#kubeflow-notebooks)
  - [Kubeflow Pipelines](#kubeflow-pipelines)
  - [Kubeflow Spark Operator (Helm)](#kubeflow-spark-operator-helm)

## Unified Installation (Kustomize)

A unified `kustomization.yaml` is provided to install Istio and the Kubeflow Dashboard, Notebooks, and Pipelines components together.

**Important**: Istio is a prerequisite and will be installed first as part of this process.

From this directory, run:
```bash
kubectl apply -k .
```

---

## Component Details

### Istio

Istio is a service mesh that provides core functionality for Kubeflow, including traffic management, security, and observability. It is installed as a prerequisite for the other components.

For detailed installation instructions, troubleshooting, and configuration options, see the [Istio Installation Guide](istio/Readme.md).

### Kubeflow Dashboard

The Central Dashboard for Kubeflow.

**Accessing the Dashboard**

Once the installation is complete, you can access the Central Dashboard by port-forwarding the `istio-ingressgateway` service:

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
```

You can then open your web browser and navigate to `http://localhost:8080`.

### Kubeflow Notebooks

This installs the Notebook Controller and the Jupyter Web App.

**Accessing Notebooks**

After installation, you can access the Jupyter Web App through the Kubeflow Central Dashboard.

### Kubeflow Pipelines

This installs Kubeflow Pipelines.

**Post-Installation Step**

After applying the kustomization, wait for the `Application` Custom Resource Definition (CRD) to be established in the cluster before proceeding:

```bash
kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
```

**Accessing the Pipelines UI**

Once the deployment is complete, you can access the Kubeflow Pipelines UI by port-forwarding the `ml-pipeline-ui` service:

```bash
kubectl port-forward -n kubeflow svc/ml-pipeline-ui 8080:80
```

You can then open your web browser and navigate to `http://localhost:8080` to view the Pipelines UI.

---

### Kubeflow Spark Operator (Helm)

The Spark Operator is installed using Helm, as this is the recommended method.

**Installation Steps**

1.  **Add the Helm Repository**:
    ```bash
    helm repo add spark-operator https://kubeflow.github.io/spark-operator
    helm repo update
    ```

2.  **Install the Operator**:
    Install the Spark Operator into a dedicated namespace.
    ```bash
    helm install spark-operator spark-operator/spark-operator \
      --namespace kube-flow \
      --create-namespace
    ```

3.  **Enable the Mutating Admission Webhook (Optional but Recommended)**:
    For more advanced features, you can enable the mutating admission webhook.
    ```bash
    helm install main spark-operator/spark-operator \
      --namespace kube-flow \
      --create-namespace \
      --set webhook.enable=true
    ```

**What is the Mutating Admission Webhook?**

In Kubernetes, an **admission webhook** is like a gatekeeper for the Kubernetes API. When you try to create or modify a resource (like a Pod), the API server can send that request to a registered webhook for approval. A **mutating** webhook can actively change the request before it's processed.

The Spark Operator's mutating webhook is an optional but powerful feature that **automatically modifies the Spark driver and executor pods** right before they are created.

Key functions include:

1.  **Mounting Volumes and ConfigMaps:** It can automatically attach storage volumes or `ConfigMaps` to your Spark pods. This is extremely useful for providing configuration files like `spark-defaults.conf` without having to build them into your Docker image.

2.  **Setting Scheduling Rules:** It can inject pod affinity/anti-affinity rules to control which nodes your Spark pods run on.

3.  **Adding Tolerations:** It allows pods to be scheduled on specific nodes that have "taints" (nodes that are reserved for certain workloads).

In short, the mutating webhook **simplifies the management of Spark applications** by allowing you to define advanced configurations declaratively in your `SparkApplication` resource, and then automatically applying those configurations to all the underlying pods.