# NFS Dynamic Storage Provisioner

This Provisions an NFS Server inside of your cluster. The twist here is that it deploys it strictly on your master node which is already holding your etcd data anyway.

## Installation

Simply run

```
kubectl apply -k nfs-storage
```

## Taints and Tolerations

The deployment definition uses tolerations to deploy the storage on the master node depending on the configuration of your cluster you might need to change them

The current tolerations are based on rancher generated clusters (rancher or rke) so if the cluster was deployed differently you might need to first find out the taints on the master node. e.g.


You can check the taints on the master node with the following
```bash
# Get all nodes
kubectl get nodes

# Describe Master node
kubectl describe node $MasterNode
```
In the case of rancher you'll see something like

```
Taints:
    node-role.kubernetes.io/etcd=true:NoExecute
    node-role.kubernetes.io/controlplane=true:NoSchedule
```

This translates to the following tolerations in the `deployment.yaml` file

```yaml
tolerations:
    - key: node-role.kubernetes.io/etcd
      operator: Equal
      value: "true"
      effect: NoExecute
    - key: node-role.kubernetes.io/controlplane
      operator: Equal
      value: "true"
      effect: NoSchedule
```
So if your setup is different then you will need to change it accordingly