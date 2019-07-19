# Setting Up User Accounts in Kubernetes

1. First you create a namespace

```bash
kubectl create ns project
```
2. Generate Developer Key

```bash
openssl genrsa -out developer.key 2048
```

3. Generate Developer CSR

```bash
 openssl req -new -key developer.key -out developer.csr -subj "/CN=developer/O=developer"
```

4. List Kubernetes Certificates
```bash
ls -tlh /etc/kubernetes/pki/
```

5. Sign the CSR with the Kubernetes Certificate Authority
```bash
sudo openssl x509 -req -in developer.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out developer.crt -days 365
```

6. Create a Role for the namespace

```yaml
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
    namespace: project
    name: deployment-manager
rules:
  - apiGroups: ["", "extensions", "apps"]
    resources: ["deployment", "replicasets", "pods", "services"] # You can also use ["*"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"] # You can also use ["*"]
```

7. Create Role Binding
```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
    namespace: project
    name: deployment-manager-binding
subjects:
  - kind: User
    name: developer
    apiGroup: ""
roleRef:
    kind: Role
    name: deployment-manager
    apiGroup: ""
```

8. After applying download the certs using

```bash
scp username@172.17.223.148:~/dev-certs/* /Users/Ody/Desktop/certs/
```
then we proceed to the developers machine...

9. We set the credentials and the local context
```bash
# Setup Dev Credentials
kubectl config set-credentials developer --client-certificate=developer.crt --client-key=developer.key

# Setup local Context
kubectl config set-context local --cluster=local-cluster --namespace=trebbble --user=developer
```