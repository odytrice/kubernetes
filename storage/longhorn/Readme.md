# Longhorn Storage Provisioner

Longhorn is a lightweight, reliable, and powerful distributed block storage system for Kubernetes.

Longhorn implements distributed block storage using containers and microservices. Longhorn creates a dedicated storage controller for each block device volume and synchronously replicates the volume across multiple replicas stored on multiple nodes. The storage controller and replicas are themselves orchestrated using Kubernetes.

See [Documentation](https://longhorn.io/docs/) for more information

## Installation

Simply Run

```bash
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/deploy/longhorn.yaml
```

To Ensure that Everything is working

```bash
kubectl get pods --namespace longhorn-system
```

It should show something like this
```
NAME                                       READY   STATUS    RESTARTS   AGE
csi-attacher-5cc849c8dd-7s8xb              1/1     Running   0          77s
csi-attacher-5cc849c8dd-th8gj              1/1     Running   0          77s
csi-attacher-5cc849c8dd-zcfkl              1/1     Running   0          77s
csi-provisioner-74557755-9zlnt             1/1     Running   0          76s
csi-provisioner-74557755-qtc6j             1/1     Running   0          76s
csi-provisioner-74557755-sz7pv             1/1     Running   0          76s
csi-resizer-686bd4b6d7-2sl6c               1/1     Running   0          76s
csi-resizer-686bd4b6d7-v8x6z               1/1     Running   0          76s
csi-resizer-686bd4b6d7-zhfgz               1/1     Running   0          76s
engine-image-ei-eee5f438-276hq             1/1     Running   0          116s
engine-image-ei-eee5f438-284hs             1/1     Running   0          116s
instance-manager-e-64537b18                1/1     Running   0          99s
instance-manager-e-bcb82b09                1/1     Running   0          116s
instance-manager-r-55759702                1/1     Running   0          115s
instance-manager-r-8b0b972c                1/1     Running   0          99s
longhorn-csi-plugin-9w9cv                  2/2     Running   0          76s
longhorn-csi-plugin-jn7m4                  2/2     Running   0          76s
longhorn-driver-deployer-cd74cb75b-m2gpl   1/1     Running   0          2m11s
longhorn-manager-cfxk4                     1/1     Running   0          2m14s
longhorn-manager-p5h2q                     1/1     Running   0          2m14s
longhorn-ui-8486987944-lz8s5               1/1     Running   0          2m12s
```

### Troubleshooting
If not, you need to wait until all the pods are running.

if `longhorn-manager` is crashing due to

```
ERRO[0000] Failed environment check, please make sure you have iscsiadm/open-iscsi installed on the host
FATA[0000] Error starting manager: Environment check failed: Failed to execute: nsenter [--mount=/host/proc/1/ns/mnt --net=/host/proc/1/ns/net iscsiadm --version], output nsenter: failed to execute iscsiadm: No such file or directory
, error exit status 1
```

You might need to install open-iscsi. To install simply run

```bash
sudo apt-get update
sudo apt-get install -y open-iscsi
```

You can confirm that it has been installed using
```bash
kubectl get storageclass
```

and you should see a storage class called longhorn

## Make Longhorn the Default Storage Class

First you need to mark the other storage classes if any as non-default. replace `$storageclass` with the name of the storage class (e.g. nfs-provisioner) and then apply the following

NOTE: you must use bash because of the quotes. otherwise, you have to put a backslash (\\) in front of every quote (")

```bash
kubectl patch storageclass $storageclass -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
```

and then you mark longhorn as the default storage class
```bash
kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```
