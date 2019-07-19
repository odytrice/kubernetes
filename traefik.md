# Setup Traefik Kubernetes Ingress Controller

1. Clone this Repo
2. Change the toml config in the [traefik-config-map.yaml](traefik/traefik-config-map.yaml)
3. Change Kustomization file as you see fit
4. Apply Kustomization
    - For kubectl version 1.15 and above run `kubectl apply -k traefik`
    - Download and install [Kustomize](https://github.com/kubernetes-sigs/kustomize) then run `kustomize build traefik | kubectl apply -f -`
