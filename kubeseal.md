# Manage Kubernetes Secrets with Kubeseal

[Sealed Secrets](https://github.com/bitnami/sealed-secrets) lets you store
encrypted Kubernetes secrets in Git. It consists of:

- The Sealed Secrets controller running in the cluster.
- The `kubeseal` client used to encrypt a Kubernetes `Secret` into a `SealedSecret`.

Only a controller or recovery operator with the matching private sealing key
can decrypt a `SealedSecret`. The controller creates a normal Kubernetes
`Secret` for workloads to consume.

> A generated Kubernetes `Secret` is still only base64 encoded inside the
> cluster. Protect it with Kubernetes RBAC and enable encryption at rest for
> etcd. Sealed Secrets protects secret values outside the cluster; it does not
> replace runtime secret security.

**Access-control warning:** Sealed Secrets does not authenticate the author of a
resource. Anyone allowed to create or update a `SealedSecret` can ask the
controller to create or replace Secret values. Restrict write access with RBAC
and admission policy, and require review for changes to sealed resources.

## Prerequisites

- A working `kubectl` context for the target cluster.
- Cluster administrator access to install a custom resource definition and
  cluster-wide RBAC.
- `kubectl` with built-in Kustomize support if you intend to customize the
  controller manifest.

The examples use Sealed Secrets `v0.38.4`, which is the current stable release
at the time of writing. Check the
[latest release](https://github.com/bitnami/sealed-secrets/releases/latest)
and its release notes before installing or upgrading. Keep the controller and
`kubeseal` client on supported versions.

## Install the Controller

The official release manifest installs the controller and the `SealedSecret`
CRD in the `kube-system` namespace. It names the controller
`sealed-secrets-controller`, which matches the default expected by `kubeseal`.

Confirm that `kubectl` points to the intended cluster before installing:

```bash
kubectl config current-context
kubectl cluster-info
```

Download the version-pinned manifest and verify its published SHA-256 asset
digest before applying it:

```bash
set -euo pipefail

SEALED_SECRETS_VERSION="0.38.4"
CONTROLLER_MANIFEST="controller-v${SEALED_SECRETS_VERSION}.yaml"
CONTROLLER_SHA256="8334764279b7dc3c758ce954c5e08cbf6d959bd977db49b872b2b722a123b202"
RELEASE_URL="https://github.com/bitnami/sealed-secrets/releases/download"

curl -fL \
  "${RELEASE_URL}/v${SEALED_SECRETS_VERSION}/controller.yaml" \
  -o "$CONTROLLER_MANIFEST"
printf '%s  %s\n' "$CONTROLLER_SHA256" "$CONTROLLER_MANIFEST" \
  | sha256sum --check -
kubectl apply -f "$CONTROLLER_MANIFEST"
```

On Windows, use `Get-FileHash` to compare the downloaded file with
`CONTROLLER_SHA256` before running `kubectl apply`.

Wait for the controller and confirm that the CRD is available:

```bash
kubectl rollout status deployment/sealed-secrets-controller \
  --namespace kube-system \
  --timeout=120s

kubectl get customresourcedefinition sealedsecrets.bitnami.com
kubectl get pods --namespace kube-system -l name=sealed-secrets-controller
```

The default controller has cluster-wide permissions to get, list, watch,
create, update, and delete Secrets. Treat it and its service account as
privileged. Multi-tenant clusters that require stronger isolation should use
namespace-scoped controllers and matching RBAC rather than the default
cluster-wide manifest.

The official manifest references a version tag rather than an immutable image
digest. Production clusters should enforce an image signature or digest policy
and verify the controller image using the upstream release guidance.

### Customize with Kustomize

Use Kustomize rather than editing the downloaded release manifest. Download
`controller-v0.38.4.yaml` into a local directory and reference it from a
`kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - controller-v0.38.4.yaml
```

Add patches to that Kustomization and apply it with:

```bash
kubectl apply -k ./sealed-secrets-controller
```

Keep the release manifest pinned. Review the upstream diff and release notes
before replacing it with a newer version. If you change the controller name or
namespace, pass the matching `--controller-name` and
`--controller-namespace` flags to every cluster-connected `kubeseal` command.

## Install Kubeseal

Install the client on the machine where secrets will be sealed.

### Linux

```bash
set -euo pipefail

KUBESEAL_VERSION="0.38.4"
ARCHIVE="kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
ARCHIVE_SHA256="ab5ae808b0efcb167a825b6cf7f3a7c0034bd99a6301d78db2012da651a8c0b9"
RELEASE_URL="https://github.com/bitnami/sealed-secrets/releases/download/v${KUBESEAL_VERSION}"

curl -fLO "${RELEASE_URL}/${ARCHIVE}"
printf '%s  %s\n' "$ARCHIVE_SHA256" "$ARCHIVE" | sha256sum --check -
tar -xzf "$ARCHIVE" kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm "$ARCHIVE" kubeseal
```

Use the matching release archive for ARM or ARM64 systems. Checksums and
signatures are published on the
[release page](https://github.com/bitnami/sealed-secrets/releases/tag/v0.38.4).

### macOS

```bash
brew install kubeseal
```

### Windows

Run the following in PowerShell:

```powershell
$ErrorActionPreference = "Stop"
$version = "0.38.4"
$installDirectory = Join-Path $env:LOCALAPPDATA "Programs\kubeseal"
$archiveName = "kubeseal-$version-windows-amd64.tar.gz"
$archive = Join-Path $env:TEMP $archiveName
$releaseUrl = "https://github.com/bitnami/sealed-secrets/releases/download"
$expected = "a7cb5c78ebb53538862f86434c07626f3e1d0ec627abe9a78fa3a4ed87ecdc18"

New-Item -ItemType Directory -Force -Path $installDirectory | Out-Null
Invoke-WebRequest `
  -Uri "$releaseUrl/v$version/$archiveName" `
  -OutFile $archive

$actual = (Get-FileHash -Algorithm SHA256 $archive).Hash.ToLowerInvariant()
if ($actual -ne $expected) {
  throw "kubeseal archive checksum verification failed"
}

tar -xzf $archive -C $installDirectory kubeseal.exe
Remove-Item $archive

$env:Path = "$installDirectory;$env:Path"
```

Add `$installDirectory` to your user `PATH` to make `kubeseal` available in
future PowerShell sessions.

Verify the installation:

```bash
kubeseal --version
```

## Fetch the Public Certificate

`kubeseal` can contact the controller through the Kubernetes API whenever it
seals a secret. You can instead fetch the public certificate once and seal
without live cluster access:

```bash
kubeseal --fetch-cert \
  --controller-name sealed-secrets-controller \
  --controller-namespace kube-system \
  --sealed-secret-file cluster-sealed-secrets.pem
```

The same command in PowerShell is:

```powershell
kubeseal --fetch-cert `
  --controller-name sealed-secrets-controller `
  --controller-namespace kube-system `
  --sealed-secret-file cluster-sealed-secrets.pem
```

The public certificate is not secret and can be distributed to people or
automation that need to seal secrets. Verify that it came from the intended
cluster before trusting it. Record its SHA-256 fingerprint for comparison:

```bash
openssl x509 -in cluster-sealed-secrets.pem -noout -fingerprint -sha256
```

The controller renews sealing keys periodically, so refresh offline
certificates regularly. Old sealing keys remain available to decrypt existing
`SealedSecret` resources unless an administrator removes them.

## Create and Seal a Secret

The following Bash example reads a value without saving it in shell history or
writing a plaintext Secret manifest. It seals the Secret for the exact name
`app-credentials` in the `demo` namespace:

```bash
kubectl create namespace demo --dry-run=client --output yaml \
  | kubectl apply -f -

read -rsp "Application password: " APP_PASSWORD
printf '\n'

printf %s "$APP_PASSWORD" \
  | kubectl create secret generic app-credentials \
      --namespace demo \
      --from-file=password=/dev/stdin \
      --dry-run=client \
      --output yaml \
  | kubeseal \
      --controller-name sealed-secrets-controller \
      --controller-namespace kube-system \
      --scope strict \
      --format yaml \
      --sealed-secret-file app-credentials.sealed.yaml

unset APP_PASSWORD
```

You can seal with a previously fetched public certificate instead of
contacting the controller:

```bash
kubeseal \
  --cert cluster-sealed-secrets.pem \
  --scope strict \
  --format yaml \
  --secret-file secret.yaml \
  --sealed-secret-file secret.sealed.yaml
```

In this file-based form, `secret.yaml` contains plaintext. Never commit it,
securely delete it after sealing, and prefer an in-memory pipeline where
possible. Only the generated `*.sealed.yaml` file should be committed.

Inspect the generated resource before applying it. It should be a
`bitnami.com/v1alpha1` `SealedSecret`, not a `v1` `Secret` containing `data` or
`stringData`.

Validate the resource and apply it only if validation succeeds:

```bash
if ! kubeseal --validate \
    --controller-name sealed-secrets-controller \
    --controller-namespace kube-system \
    < app-credentials.sealed.yaml; then
  printf '%s\n' "SealedSecret validation failed; resource was not applied." >&2
  exit 1
fi

kubectl apply -f app-credentials.sealed.yaml || exit 1

kubectl wait sealedsecret/app-credentials \
  --namespace demo \
  --for=condition=Synced \
  --timeout=60s

kubectl get sealedsecret app-credentials --namespace demo
kubectl get secret app-credentials --namespace demo
```

Do not decode or print the generated Secret merely to verify that it exists.

## Use a SealedSecret with Kustomize

Add the generated resource to the application Kustomization like any other
manifest:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: demo
resources:
  - deployment.yaml
  - app-credentials.sealed.yaml
```

Install the controller and CRD before applying application Kustomizations that
contain `SealedSecret` resources:

```bash
kubectl apply -k ./application
```

With strict scope, the name and namespace in the rendered Kustomize output must
match the values used while sealing. Do not apply `namePrefix`, `nameSuffix`, a
different `namespace`, or name-changing patches after sealing. Seal against the
final rendered metadata, and verify that workload `secretRef` values still
refer to the generated Secret name.

For Docker registry credentials, generate a `kubernetes.io/dockerconfigjson`
Secret with `kubectl create secret docker-registry --dry-run=client`, then pipe
it through `kubeseal` in the same way. See
[Setup Private Registry](pull-secrets.md) for service account and
`imagePullSecrets` configuration.

TLS and file-based secrets follow the same pattern:

```bash
kubectl create secret tls ingress-tls \
  --namespace demo \
  --cert ./tls.crt \
  --key ./tls.key \
  --dry-run=client \
  --output yaml \
| kubeseal \
    --controller-name sealed-secrets-controller \
    --controller-namespace kube-system \
    --scope strict \
    --format yaml \
    --sealed-secret-file ingress-tls.sealed.yaml
```

Keep source private keys and credential files out of Git.

## Choose a Scope

Scope binds encrypted values to Kubernetes object metadata. Use the narrowest
scope that supports the deployment workflow.

| Scope | Binding | Use |
| --- | --- | --- |
| `strict` | Exact secret name and namespace | Default and recommended |
| `namespace-wide` | Namespace only | Rename within its namespace |
| `cluster-wide` | No name or namespace binding | Use in key-sharing clusters |

Select a broader scope only when required:

```bash
kubeseal --scope namespace-wide --format yaml \
  --secret-file secret.yaml \
  --sealed-secret-file secret.sealed.yaml

kubeseal --scope cluster-wide --format yaml \
  --secret-file secret.yaml \
  --sealed-secret-file secret.sealed.yaml
```

`kubeseal` adds the matching scope annotation to the generated `SealedSecret`.
With strict scope, changing either `metadata.name` or `metadata.namespace`
after sealing causes decryption to fail. Broader scopes make encrypted values
more portable, but they reduce protection against copying a sealed value to a
Secret that a different user can read.

Scope does not provide cross-cluster portability. A cluster-wide resource can
only be decrypted by clusters that possess the matching private sealing key.

## Update and Rotate Secrets

To replace a secret value, generate a new `SealedSecret` with the same name,
namespace, and scope, then apply it. Rotating the actual password, token,
certificate, or key remains your responsibility.

To update one item without knowing the plaintext values of the other items,
pipe a Secret containing only the changed item to `kubeseal --merge-into`:

```bash
read -rsp "New application password: " NEW_PASSWORD
printf '\n'

printf %s "$NEW_PASSWORD" \
  | kubectl create secret generic app-credentials \
      --namespace demo \
      --from-file=password=/dev/stdin \
      --dry-run=client \
      --output yaml \
  | kubeseal \
      --controller-name sealed-secrets-controller \
      --controller-namespace kube-system \
      --scope strict \
      --format yaml \
      --merge-into app-credentials.sealed.yaml

unset NEW_PASSWORD
```

After automatic sealing-key renewal, `kubeseal --re-encrypt` can encrypt an
existing `SealedSecret` with the newest cluster key without sending plaintext
back to the client:

```bash
kubeseal --re-encrypt \
  --controller-name sealed-secrets-controller \
  --controller-namespace kube-system \
  --secret-file app-credentials.sealed.yaml
```

When only `--secret-file` is provided, `kubeseal` replaces the file atomically
after successful re-encryption.

Re-encryption is not credential rotation. If an old private sealing key was
compromised, assume every committed `SealedSecret` encrypted by that key can be
decrypted. Renew the sealing key first, then rotate the underlying credentials
and seal their new values.

## Back Up and Restore Sealing Keys

Without the controller private keys, existing `SealedSecret` resources cannot
be recovered after losing the cluster. Back up all sealing keys after
installation and after key renewal:

```bash
BACKUP_DIRECTORY="/secure/path/outside-this-repository"
BACKUP_FILE="$BACKUP_DIRECTORY/sealed-secrets-keys.yaml"
TEST_SEALED_SECRET="app-credentials.sealed.yaml"
KEY_SELECTOR="sealedsecrets.bitnami.com/sealed-secrets-key"
CONTROLLER_NAMESPACE="kube-system"
umask 077

if ! KEY_NAMES=$(kubectl get secrets \
  --namespace "$CONTROLLER_NAMESPACE" \
  --selector "$KEY_SELECTOR" \
  --output name); then
  exit 1
fi

if [ -z "$KEY_NAMES" ]; then
  printf '%s\n' "No sealing keys found; existing backup was not changed." >&2
  exit 1
fi

BACKUP_TMP=$(mktemp "$BACKUP_DIRECTORY/sealed-secrets-keys.XXXXXX")
chmod 600 "$BACKUP_TMP"

if kubectl get secrets \
    --namespace "$CONTROLLER_NAMESPACE" \
    --selector "$KEY_SELECTOR" \
    --output yaml > "$BACKUP_TMP" \
  && kubeseal --recovery-unseal \
    --recovery-private-key "$BACKUP_TMP" \
    < "$TEST_SEALED_SECRET" > /dev/null; then
  mv -f "$BACKUP_TMP" "$BACKUP_FILE"
else
  rm -f "$BACKUP_TMP"
  exit 1
fi
```

> Replace `/secure/path/outside-this-repository` with an encrypted backup
> location. The file contains private keys. Never place it in this repository,
> restrict access to it, and test the recovery procedure. Set
> `TEST_SEALED_SECRET` to a known good sealed resource so the new backup is
> proven able to decrypt it before replacing the previous backup.

Restore the key Secrets before starting the controller. If the controller is
already running, apply the backup and restart its pod:

```bash
BACKUP_FILE="/secure/path/outside-this-repository/sealed-secrets-keys.yaml"
CONTROLLER_NAMESPACE="kube-system"
CONTROLLER_SELECTOR="name=sealed-secrets-controller"
CONTROLLER_DEPLOYMENT="sealed-secrets-controller"
kubectl apply -f "$BACKUP_FILE"
kubectl delete pod \
  --namespace "$CONTROLLER_NAMESPACE" \
  --selector "$CONTROLLER_SELECTOR"
kubectl rollout status "deployment/$CONTROLLER_DEPLOYMENT" \
  --namespace "$CONTROLLER_NAMESPACE" \
  --timeout=120s
```

For offline disaster recovery, a key backup can decrypt a sealed resource locally:

```bash
RECOVERY_DIRECTORY="/secure/path/outside-this-repository"
BACKUP_FILE="$RECOVERY_DIRECTORY/sealed-secrets-keys.yaml"
RECOVERED_SECRET="$RECOVERY_DIRECTORY/recovered-secret.yaml"
umask 077

RECOVERED_TMP=$(mktemp "$RECOVERY_DIRECTORY/recovered-secret.XXXXXX")
chmod 600 "$RECOVERED_TMP"

if kubeseal --recovery-unseal \
    --recovery-private-key "$BACKUP_FILE" \
    --format yaml \
    < app-credentials.sealed.yaml > "$RECOVERED_TMP"; then
  mv -f "$RECOVERED_TMP" "$RECOVERED_SECRET"
else
  rm -f "$RECOVERED_TMP"
  exit 1
fi
```

The output is a plaintext Kubernetes `Secret`. Handle it as sensitive data and
securely delete it after recovery.

## Troubleshooting

### Inspect the Resource and Controller

```bash
kubectl describe sealedsecret app-credentials --namespace demo
kubectl get events --namespace demo --sort-by=.lastTimestamp
kubectl logs \
  --namespace kube-system \
  --selector name=sealed-secrets-controller
```

### `cannot fetch certificate`

- Confirm the current `kubectl` context.
- Confirm that the controller pod and service exist in `kube-system`.
- Pass the correct `--controller-name` and `--controller-namespace`.
- Fetch the certificate once and use `--cert` if the API server cannot proxy to
  the controller service.

### `no key could decrypt secret`

- Confirm that the sealed resource was created for this cluster's certificate.
- Under strict scope, restore the exact name and namespace used while sealing.
- Confirm that the required old sealing keys still exist in the controller namespace.
- Run `kubeseal --validate` against the target cluster.

### The `SealedSecret` exists but the `Secret` does not

- Inspect `.status.conditions` and events with `kubectl describe`.
- Check controller logs for decryption, RBAC, or template errors.
- Confirm that the controller watches the resource's namespace.

## Uninstall

List all sealed resources before removing the controller:

```bash
kubectl get sealedsecrets --all-namespaces
```

Back up the sealing keys and decide how each generated Secret should be
handled. Generated Secrets normally have an owner reference to their
`SealedSecret`; deleting the sealed resource can also delete the Secret.

When it is safe to remove all Sealed Secrets resources and the CRD, use the
same installation source. For the unmodified release manifest, run:

```bash
kubectl delete -f controller-v0.38.4.yaml
```

For a customized installation, delete the rendered Kustomization instead:

```bash
kubectl delete -k ./sealed-secrets-controller
```

Do not delete the CRD or sealing keys until you have confirmed that no
encrypted resources need to be recovered.

## References

- [Sealed Secrets documentation](https://github.com/bitnami/sealed-secrets)
- [Sealed Secrets releases](https://github.com/bitnami/sealed-secrets/releases)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kustomize](https://kustomize.io/)
