# Installing SonarQube


To install SonarQube, simply clone this repository,  change the `ingress.yaml` and probably `configmap.yaml` and then  simply run

```bash
kubectl apply -k sonarqube
```