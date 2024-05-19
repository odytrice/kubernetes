# Setup Private Registry

## Docker Hub Private Registry

First we need to create the secret from our docker credentials. Make sure you run this in the correct namespace

```bash
kubectl create secret docker-registry docker-pull-secret --docker-server=https://index.docker.io/v1/ --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email>
```

Once the secret is created, we can simply patch the `default` service account in the namespace since this is the service account that pods use by default.

```bash
# Note: This command only works in bash or zsh. It doesn't work with cmd or powershell due to single quotes
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "docker-pull-secret"}]}'
```

An Alternative would be to run

```
kubectl edit serviceaccount default
```

This will launch an editor and then you can update it with the `imagePullSecrets` section to look the following:

```yaml
# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2023-11-19T05:45:00Z"
  name: default
  namespace: nomad
  resourceVersion: "58835"
  uid: a5d5b68c-b10a-4adb-832c-5c92ff5f69c0
imagePullSecrets:
- name: docker-pull-secret
```

## Google Container Registry

### Prerequisites
1. Create a service account in the google console for the project. Make sure it has permissions to read the registry
2. Download the json key for the service account store it as `image-pull-sa-key.json`
3. Make sure you are in the correct namespace (e.g. appNs)

### Create the gcr-pull-secret

```bash
kubectl create secret docker-registry gcr-pull-secret --docker-server=eu.gcr.io --docker-username=_json_key --docker-email=youremail@gmail.com --docker-password="$(cat image-pull-sa-key.json)"
```
** Note that this only works in `bash` as powershell doesn't treat the `cat` command well


Patch the default service account adding the pull secrets to the default service account of the namespace

```bash
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gcr-pull-secret"}]}'
```
## Access Google Cloud Storage from Pods
Create a Google service account that is allowed to write files to the google storage bucket you specify in the setup make sure it has the `storage admin` role:

```bash
kubectl create secret generic google-storage --from-file=key.json=google-storage-sa-key.json
```

just make sure that the `google-storage` secret is mounted properly into your pods for access


## Sample Script

You can put it all together into a script that creates a new namespace, pull-secret and configures the service account

```bash
#!/bin/bash
namespace=$1

username=<docker-username>
password=<docker-password>
email=<docker-email>

echo "Creating Namespace $namespace"
kubectl create ns $namespace

echo "Create DockerHub Image Pull Secret in $namespace namespace"
kubectl create secret docker-registry docker-pull-secret --docker-server=https://index.docker.io/v1/ --docker-username=$username --docker-password=$password --docker-email=$email -n $namespace

echo "Patch $namespace Default Service Account"
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "docker-pull-secret"}]}' -n $namespace
```
