---
reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
---

# Manual Storage Provisioning

This is useful for testing, single node deployments or even manual configuration of workloads. Essentially It allows you to create a [Persistsent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (PV) out of a directory on the host and then have that volume bound to any existing Persistent Volume Claim (PVC).

This is a good way to seperate the Volume/Storage Claims of your application from the actual implementation in your specific cluster or environment. You can see more details here [Configure Persistent Volume Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)

## Create the Volume
First we create the folder

```bash
mkdir /mnt/storage/task-volume
```

Next we create the Yaml file for the Persistent Volume

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/storage/task-volume"
```

Pay attention to the `storageClassName` as that will be necessary to match Persistent Volume Claims.

You can then create persistent volume claim with the following.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

And use it with your Pod as follows

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage
```