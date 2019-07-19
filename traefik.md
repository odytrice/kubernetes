# Setup Traefik Kubernetes Ingress Controller

1. Clone this Repo
2. Apply Kustomization
    a. For kubectl version 1.15 and above run `kubectl apply -k traefik`
    b. Download and install [Kustomize](https://github.com/kubernetes-sigs/kustomize) then run `kustomize build traefik | kubectl apply -f -`
