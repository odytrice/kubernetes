# Forcefully delete Resources

**DANGER - Forcefully deleteing objects can leave resources in the cluster dangling. use with extreme caution**


Sometimes when you want to delete a particular resource in Kubernetes, It get's stuck in a `Terminating` phase. This is typically because the object's finalizer is no longer in the cluster.
This invalid state can come as a result of using tools like Helm which creates custom resources during installation and does not edit or remove them during an uninstall.


To force delete, you take the following steps
1. Edit the Object e.g. `kubectl edit pod pod-name` or `kubectl edit customresource/name`
2. Remove delete the custom finalizers. If the finalizer has only a "kubernetes" finalizer then you can ignore it as it will be recreated if you remove it
3. go ahead and delete the object `kubectl delete customresource/name`

## Forcefully remove namespaces
If you want to forcefully delete a namespace, It's a bit trickier because as long as it contains valid objects kubernetes will not remove it. Even if you clear the finalizers. It will still be stuck in the Terminating phase.

To fix this, you need to first identify all the objects in the namespace including custom resources. To do that you simply
run

NOTE: Make sure you run this command in bash as windows adds a `/r` which causes errors
```bash
kubectl api-resources --verbs=list --namespaced -o name  | xargs -n 1 kubectl get --show-kind --ignore-not-found
```

This will list all the resources in the namespace. For each of them, you will need to force delete them one by one
