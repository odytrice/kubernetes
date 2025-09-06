# Istio Installation for Kubeflow

Istio is a service mesh that provides core functionality for Kubeflow, including traffic management, security, and observability. It is installed as a prerequisite for the other components.

## Installation

If you need to install Istio separately or want more control over the installation process, follow these steps:

1. **Install istioctl**:

   **Windows:**
   ```powershell
   # Using Chocolatey
   choco install istioctl

   # Or using Scoop
   scoop install istioctl
   ```

   **macOS:**
   ```bash
   # Using Homebrew
   brew install istioctl
   ```

   **Linux:**
   ```bash
   # Using package managers or direct download
   curl -sL https://istio.io/downloadIstioctl | sh -
   sudo mv $HOME/.istioctl/bin/istioctl /usr/local/bin/
   ```

2. **Install Istio with minimal profile** (recommended for Kubeflow):
   ```bash
   istioctl install --set values.defaultRevision=default
   ```

3. **Enable automatic sidecar injection** for the kube-flow namespace:
   ```bash
   kubectl create namespace kube-flow
   kubectl label namespace kube-flow istio-injection=enabled
   ```

4. **Verify the installation**:
   ```bash
   kubectl get pods -n istio-system
   ```

## Configuration for Kubeflow

Kubeflow requires specific Istio configurations. The unified installation handles this automatically, but for manual installations, ensure:

- The `istio-ingressgateway` service is properly configured
- The kubeflow namespace has istio-injection enabled
- Istio's default profile or minimal profile is used (avoid demo profile in production)

## Troubleshooting

### Common Issues

**Pods not starting after Istio installation:**
- Check that the istio-system namespace has all pods running
- Verify that the kubeflow namespace has istio-injection enabled

**Gateway not accessible:**
- Ensure the istio-ingressgateway service is running and has an external IP
- Check that your firewall/security groups allow traffic on the gateway ports

**Sidecar injection not working:**
- Verify the namespace has the `istio-injection=enabled` label
- Check that the mutating webhook is running in the istio-system namespace

### Useful Commands

```bash
# Check Istio installation status
istioctl version

# Analyze configuration issues
istioctl analyze

# Check proxy configuration for a pod
istioctl proxy-config cluster <pod-name> -n <namespace>

# Get ingress gateway external IP
kubectl get svc istio-ingressgateway -n istio-system
```

## Uninstalling Istio

To completely remove Istio from your cluster:

```bash
# Remove Istio installation
istioctl uninstall --purge

# Remove the istio-system namespace
kubectl delete namespace istio-system
```