# Installing Kubernetes
Setting up a Kubernetes Cluster on a Bare metal machine

Full Instructions are here [Kubernetes Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

Full Video [Setup Kubernetes Cluster Step by Step](https://www.youtube.com/watch?v=UWg3ORRRF60)



## Prerequisites
  - Ubuntu 16.04 or higher


## Master Installation
1. First we need to escalate priviledges
```bash
sudo bash
```
2. First we need to update our package source

```bash
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

3. Then we need to install the main commands

```bash
sudo apt-get install docker.io kubeadm kubectl kubelet kubernetes-cni
```


Install and Configure Docker to use `systemd`
```bash
# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update && apt-get install apt-transport-https ca-certificates curl software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update && apt-get install docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker
```

Enable Docker

```bash
systemctl enable docker.service
```

Then we need to disable swap

```bash
# Check for Swap files
cat /proc/swaps

# Disable Swap
swapoff -a

# Delete any swap entries
vi /etc/fstab

```

3. Install the Cluster

```bash
kubeadm init
```

Copy out the join command

```bash
# e.g.
kubeadm join 172.17.223.148:6443 --token mqpui3.rlwk2qz2zvq9amnc --discovery-token-ca-cert-hash sha256:50ca6ffcde8076c39b436cec47eb1b906e058f51928af468d5eb09152fa6fede
```

4. Drop Down to a Regular User and install

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

5. Install Weave Overlay Network

```bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

## Worker Installation

You need to repeat all the prerequisites above. If there are no worker nodes i.e. single node installation of Kubernetes, simply untaint the control pane with the following

```bash
kubectl taint nodes --all node-role.kubernetes.io/master-
```