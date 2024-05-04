---
reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
---

# Manual Storage Provisioning

This is useful for testing, single node deployments or even manual configuration of workloads. Essentially It allows you to create a [Persistsent Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (PV) out of a directory on the host and then have that volume bound to any existing Persistent Volume Claim (PVC).

This is a good way to seperate the Volume/Storage Claims of your application from the actual implementation in your specific cluster or environment. You can see more details here [Configure Persistent Volume Storage](https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/)