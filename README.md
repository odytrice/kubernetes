# Kubernetes Tutorials
Documentation on How to setup and Manage a Kubernetes Cluster from Scratch

## Installing Clusters
- [Setup a Cluster using RKE](rke.md) (Recommended)

- [Setup a Cluster using Kubeadm](installation.md)

## Cluster Essentials

### Storage

- [Local Volume Storage Provisioner](storage/local-volume/Readme.md)

- [NFS Dynamic Storage Provisioner](storage/nfs-storage/Readme.md) (Legacy)

- [NFS External Dynamic Storage Provisioner](storage/nfs-external-storage/Readme.md)

- [Longhorn Dynamic Storage Provisioner](storage/longhorn/Readme.md)

- [Manual Storage Provisioning](storage/manual.md)

### Backup

- [Longhorn Backup to S3](storage/longhorn/backup.md)

- [Cluster Backup with Velero](storage/backup.md)

### Ingress
- [Setup Nginx Ingress Controller](ingress/nginx/Readme.md)
    - [Bare Metal Deployment](ingress/nginx/bare-metal/Readme.md)

- [Setup Traefik Ingress Controller](ingress/traefik/Readme.md)

### Others

- [Setup Cert Manager](cert-manager/Readme.md)

## Cluster Management

### User Management

- [Setup remote Access using x509 Certs](user-management/generic.md)

- [Setup Access Control for Rancher (RKE)](user-management/rke.md)

### Monitoring

- [Install the Kubernetes Dashboard](dashboard/Readme.md)

- [Monitoring Using Prometheus and Grafana](monitoring/manual/Readme.md)

- [Using Kube Prometheus Stack](monitoring/operator/Readme.md)

### Others

- [Install Rancher](rancher.md)

- [Forcefully Delete Resources and Namespaces](force-delete.md)

## Tools

- [Setup Helm](helm.md)

- [Setup Private Docker Registry](pull-secrets.md)

- [Kubectx and Kubens](kubectx.md)

## Applications

- [Setup Gitlab in Kubernetes](gitlab.md)

- [Dask Gateway for Machine Learning](dask-gateway/Readme.md)

- [SonarQube](sonarqube/Readme.md)


[![Buy Me Coffee 🙏](images/buymecoffee.gif)](https://buymeacoffee.com/odytrice)

[![Contact me on Codementor](https://www.codementor.io/m-badges/odytrice/find-me-on-cm-b.svg)](https://www.codementor.io/@odytrice?refer=badge)
