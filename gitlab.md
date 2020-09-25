# Gitlab Installation

For more details check here https://docs.gitlab.com/charts/installation/deployment.html


## Pre-Requisites
For the configuration below you need the following to be installed and configured
- [Nginx Ingress Controller](ingress/nginx.md)
- [Cert Manager](cert-manager/Readme.md)

You need to have a cluster with a good amount resources. The gitlab team recommends
- A Kubernetes cluster, version 1.13 or higher.
- 8vCPU
- 30GB of RAM

However you can trim it down (see [Pre-Modification](#apply-pre-modifications))

## Configuration
You need to create the configuration for you gitlab installation. You will save this in a file called `gitlab.yaml`.

For more details see https://docs.gitlab.com/charts/charts/globals.html

```yaml
global:
  edition: ce
  hosts:
    # base domain
    domain: example.com

  shell:
    # ssh port for cloning
    port: 2222

  pod:
    labels:
      # applies label to all pods
      environment: prod

  deployment:
    annotations:
      # applies annotation to all deployments
      environment: prod

  service:
    annotations:
      # applies annotation to all services
      environment: prod

  ingress:
    class: nginx
    configureCertmanager: false
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      acme.cert-manager.io/http01-edit-in-place: "true"


certmanager:
  install: false

nginx-ingress:
  enabled: false

gitlab:
  webservice:
    ingress:
      tls:
        secretName: gitlab-webservice-tls
  gitaly:
    persistence:
      size: 2Gi

registry:
  ingress:
    tls:
      secretName: gitlab-registry-tls

postgresql:
  persistence:
    size: 2Gi
minio:
  ingress:
    tls:
      secretName: gitlab-minio-tls
  persistence:
    size: 2Gi
redis:
  persistence:
    size: 2Gi

prometheus:
  alertmanager:
    enabled: false
    persistentVolume:
      enabled: false
      size: 2Gi
  pushgateway:
    enabled: false
    persistentVolume:
      enabled: false
      size: 2Gi
  server:
    persistentVolume:
      enabled: true
      size: 2Gi
```

## Installation

First you need to ensure you create a namespace and that you are in that namespace

```bash
kubectl create ns gitlab
kubectl config set-context --current --namespace gitlab
```
Then we can run our helm chart

```bash
#Add Gitlab Chart Repo
helm repo add gitlab https://charts.gitlab.io/

# Update the Repo
helm repo update

# Install Gitlab using helm
helm install gitlab gitlab/gitlab -f ".\gitlab.yaml"
```
Once Installation is done you can retrieve the `root` password with the following command

```bash
# <name> should be the name of the gitlab installation i.e. gitlab
kubectl get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode
```
### Apply Pre-Modifications

Even though the helm chart allows you to configure a lot there are still situations where you need to have fine-grained control. For example you want to configure the number of replicas that gets created.

In this case, you will need to output the helm template to a file and then make modifications to that file and when you are okay with the output then you can simply apply the output file.

```bash
# Template to a yaml file for pre-modifications
helm template gitlab gitlab/gitlab -f ".\gitlab.yaml" > output.yaml

# After modifications to output.yaml run
kubectl apply -f output.yaml
```

## Configure SSH
In order to get SSH working, first you need to change `global.shell.port` to an port-number between 30000-32767.

After that you run the `helm template` instead and modify the output.yaml file.

You need to change the service `gitlab-shell` type to `NodePort` and then set the nodePort value on the service to a port-number you specified above

And finally you run

```bash
kubectl apply -f output.yaml
```

## Uninstallation
To uninstall gitlab we simply run

```bash
helm uninstall gitlab

# or if we used pre-modifications
kubectl delete -f output.yaml
```