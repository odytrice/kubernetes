# Kubeflow Spark Operator

The recommended and most straightforward method for installing the Kubeflow Spark Operator is by using Helm.

### Installation Steps

1.  **Add the Helm Repository**:
    ```bash
    helm repo add spark-operator https://kubeflow.github.io/spark-operator
    helm repo update
    ```

2.  **Install the Operator**:
    Install the Spark Operator into a dedicated namespace. The command below will create the `spark-operator` namespace if it doesn't already exist and install the operator there.
    ```bash
    helm install spark-operator spark-operator/spark-operator \
      --namespace spark-operator \
      --create-namespace
    ```
    By default, this installation sets up the necessary RBAC (Role-Based Access Control) for the operator to function correctly.

3.  **Enable the Mutating Admission Webhook (Optional but Recommended)**:
    For more advanced features like pod customization (e.g., mounting volumes or ConfigMaps), you should enable the mutating admission webhook.
    ```bash
    helm install my-release spark-operator/spark-operator \
      --namespace spark-operator \
      --create-namespace \
      --set webhook.enable=true
    ```

