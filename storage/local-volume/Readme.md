# Local Volume Static Provisioner

Local volumes are Persistent Volumes provisioned directly on the disk of the Node. This is very similar to hostpath with the exception that Kubernetes is aware of Data of each pod and will only re-schedule pods on the node that has the data.

The upside of this is that data access performance will be exceptional as there is no network traffic involved.

The downside is that the scheduler won't be able to flexibly reschedule pods as the local volume puts an additional constraint. The Pod has to live close to the data

## Installation

Simply Run the following from the `storage` directory

```bash
kubectl apply -k local-volume
```

For full information about installing provisioner look at the [Official Docs](https://github.com/kubernetes-sigs/sig-storage-local-static-provisioner/blob/master/docs/getting-started.md)
