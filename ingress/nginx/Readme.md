# Setup Nginx Kubernetes Ingress Controller

Nginx Ingress controller

## Express Install

To quickly install the ingress controller simply run the following

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/cloud/deploy.yaml
```

details here https://kubernetes.github.io/ingress-nginx/deploy/

After it's been deployed, you can simply run
```bash
kubectl get svc nginx-ingress --namespace=nginx-ingress
```
to get the IP Address of the loadbalancer. You need to point all domains you want to serve by the ingress controller to the IP Address of the loadbalancer.

## Bare Metal Install

To deploy the Ingress Controller on bare metal clusters or clusters that don't have access to cloud loadbalancers. We have to implement a few tweaks. For more details look at [Nginx Ingress Bare Metal Considerations](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network)

Thankfully, I have made all this modifications so you can simply follow the [Bare Metal Instructions](bare-metal/Readme.md)