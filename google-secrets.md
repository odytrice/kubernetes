# Setup Google Kubernetes Secrets

## Pulling Images from Google Conatiner Registry

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
