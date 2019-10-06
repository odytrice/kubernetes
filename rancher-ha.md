# Rancher HA Installation
Install Ubuntu on Machines.

### Steps:
  1. Copy your SSH key to Remote machine
  2. Install Docker
  3. Deploy Cluster
  4. Setup Helm
  5. Install Rancher

## 1. Setup Remote SSH

```bash
# Must strictly run this from bash shell. Either Ubuntu or WSL Ubuntu
ssh-copy-id username@server
ssh-copy-id -i ~/.ssh/id_rsa.pub username@server
```

## 2. Install Docker

Follow the instructions here https://docs.docker.com/install/linux/docker-ce/ubuntu/
```bash
# Wipe Docker
sudo apt-get remove docker docker-engine docker.io containerd runc

# Update
sudo apt-get update

# Install packages to allow apt to use repo over https
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common

# Add Docker official GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Setup Repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

Add User to Docker group
```bash
# Create Docker Group
sudo groupadd docker

# Add User to the docker Group
sudo usermod -aG docker $USER

# Activate Changes
newgrp docker
```


## 3. Deploy Cluster

First download `rke` from https://github.com/rancher/rke/releases

Then you need to describe your cluster with a `cluster.yaml` file

```yaml
cluster_name: rancher

nodes:
  - address: 192.168.1.100
    internal_address: 192.168.1.100 # Optional if the Machines use a different IP from the Public IP
    user: ody                       # username. you must have ssh access to the Server
    role: [controlplane,worker,etcd]

services:
  etcd:
    snapshot: true
    creation: 6h
    retention: 24h

network:
  plugin: weave

ingress:
  provider: nginx
```
```bash
rke up --config=".\cluster.yaml"
```

### Test Cluster

```bash
kubectl get pods --all-namespaces --kubeconfig kube_config_cluster.yml
```

## 4. Setup Helm
```bash
kubectl -n kube-system create serviceaccount tiller

kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

helm init --service-account tiller
```

## 5. Install Rancher
```bash
# Add Chart

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
```
### (Optional) Install Cert Manager
```bash
# Install Cert Manager
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml

# Create Namespace
kubectl create namespace cert-manager

# Disable Resource Validation
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true

# Add Helm Chart and update Repo
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Cert-Manager Chart
helm install --name cert-manager --namespace cert-manager --version v0.9.1 jetstack/cert-manager
```
### Install Rancher
#### Using LetsEncrypt
```bash
# Install Rancher using LetsEncrypt
helm install rancher-latest/rancher --name rancher --namespace cattle-system --set hostname=rancher.hostname.com --set ingress.tls.source=letsEncrypt
```

#### Using your own Certificates
```bash
# Install Rancher using Your Own Certs
# Make sure the tls Cert is configured in cattle-system namespace
kubectl create secret tls tls-rancher-ingress --cert=tls-dev-io.crt --key=tls-dev-io.key --namespace cattle-system

# Install using the Certs
helm install rancher-latest/rancher --name rancher --namespace cattle-system --set hostname=rancher.hostname.com --set ingress.tls.source=tls-rancher-ingress


```