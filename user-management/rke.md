## Setup User Accounts using RKE in Kubernetes


If you [setup your cluster using RKE](../rke.md) and would like to create more accounts that can access the cluster via the CLI.

This guide is a specialized form for [Setup remote Access using x509 Certs](generic.md)

Simply copy [new-user.sh](new-user.sh) into your rancher directory. That is the directory where you ran `rke up`. Typically this directory contains the following structure

```
├── cluster.rkestate
├── cluster.yml
```

The `cluster.rkestate` contains the cluster configuration including the Root CA which we need.

### Prerequisites

First you need to install [jq](https://jqlang.github.io/jq/). This is used for the Certificate Extraction

```bash
# Linux (Ubuntu)
sudo apt-get install jq

# MacOS
brew install jq

# Windows
choco install jq
```

Simply run the script

```bash
./new-user.sh <username>
```

The script will do the following

1. Create new Public/Private Key pair for the User ("username")
2. Extract the Kubernetes Certificates
3. Sign the User's credential with the cluster Credentails
4. Store everything into a `kube.config` file that you can either use directly or graft into your existing config at `~/.kube/config`