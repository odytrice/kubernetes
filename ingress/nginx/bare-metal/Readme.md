# Setup Nginx Kubernetes Ingress Controller on Bare Metal Servers

In order to deploy Nginx on Bare Metal clusters, There are [some considerations](https://kubernetes.github.io/ingress-nginx/deploy/baremetal/) that need to be made. In particular because we don't have any load balancer in front of your cluster, we need to make to main changes to the way the ingress controller is deployed

1. **Make use of `hostNetwork: true` or use `hostPort`**: This will make ports on the container map to ports on the Host itself
2. **Switch from Deployment to Daemonset**: Because we are taking the ports on the host, there can only be on nginx pod on each Node. So using a Daemonset also ensures that adding new nodes contain new deployments of the ingress pod
3. **Change the dnsPolicy for the pod to use `ClusterFirstWithHostNet`** - This will allow pods that are maked as `hostNetwork: true` to still resolve in cluster DNS Names

For the deployment I have prepared a set of kubectl files from [Ingress-Nginx Baremetal Manfiest](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/baremetal/deploy.yaml)

## Installation

First we create the `ingress-nginx` namespace

```bash
kubectl create ns ingress-nginx
```

Then we can apply it

```
kubectl apply -k ingress/nginx/bare-metal
```
