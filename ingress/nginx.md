# Setup Nginx Kubernetes Ingress Controller

Nginx Ingress controller

For more Details on Deploying the Nginx Controller you can use the docs located here

https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/

Clone the Nginx Deployment for a Specific Version

```bash
git clone https://github.com/nginxinc/kubernetes-ingress/
cd kubernetes-ingress/deployments
git checkout v1.7.2
```

### Authorization
Create the namespace and deploy RBAC authorization

```bash
# Create a namespace and a service account for Ingress controller
kubectl apply -f common/ns-and-sa.yaml
# Create a cluster role and cluster role binding for the service account:
kubectl apply -f rbac/rbac.yaml
```

### Create Configuration

```bash
# Create a secret with a TLS certificate and a key for the default server in NGINX
kubectl apply -f common/default-server-secret.yaml
kubectl apply -f common/nginx-config.yaml
```


### Deploy Ingress

Finally we deploy the ingress controller

```bash
# Deploy the Ingress Controller
kubectl apply -f deployment/nginx-ingress.yaml
```

But the ingress controller isn't connected to the outside world. To accomplish that we simply create the loadbalancer service

NOTE: This service type does not work for Amazon EKS. Please check the [documentation](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/) for details about deploying this to EKS

For Load Balancer, we can simply run the following

```bash
# Use the following for Typical cloud based clusters
kubectl apply -f service/loadbalancer.yaml
```

After it's been deployed, you can simply run

```bash
kubectl get svc nginx-ingress --namespace=nginx-ingress
```
to get the IP Address of the loadbalancer. You need to make all domains you want served by the ingress controller to this IP Address