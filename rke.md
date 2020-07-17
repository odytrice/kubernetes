# Setup a Kubernetes Cluster using RKE

## Prerequisites
**On Premise**

Before you deploy on your On Premise Machines
Install Ubuntu on Machines. All machines need to be able to ping each other directly using their corresponding IP Address (No NAT or fancy network topolgies)

**Cloud Deployment**

Allocate the Virtual Machines that you will need make sure to setup any private IP Address if applicable as machines in the

## Steps:
  1. Copy your SSH key to Remote machine
  2. Install Docker
  3. Deploy Cluster

### 1. Setup Remote SSH

```bash
# Must strictly run this from bash shell. Either Ubuntu or WSL Ubuntu
ssh-copy-id username@server
ssh-copy-id -i ~/.ssh/id_rsa.pub username@server

# For Windows (if .ssh exists)
cat ~/.ssh/id_rsa.pub | ssh user@server "cat >> ~/.ssh/authorized_keys"

# For Windows (if .ssh doesn't exist)
cat ~/.ssh/id_rsa.pub | ssh user@server "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"
```

### 2. Install Docker

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

Add User to Docker group (Optional - Unecessary if user is root)
```bash
# Create Docker Group
sudo groupadd docker

# Add User to the docker Group
sudo usermod -aG docker $USER

# Activate Changes
newgrp docker
```


### 3. Deploy Cluster

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

## Test Cluster

```bash
kubectl get pods --all-namespaces --kubeconfig kube_config_cluster.yml
```