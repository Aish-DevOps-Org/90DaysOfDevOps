# Day 51 – Kubernetes Manifests and Your First Pods

### Task 1: Create Your First Pod (Nginx)
Create a file called `nginx-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

Apply it:
```bash
kubectl apply -f nginx-pod.yaml
```

Verify:
```bash
kubectl get pods
kubectl get pods -o wide
```

```bash
azureuser@Tws-lab:~$ kubectl apply -f nginx-pod.yml
pod/nginx-pod created
azureuser@Tws-lab:~$ kubectl get pods -o wide
NAME        READY   STATUS    RESTARTS   AGE   IP           NODE                           NOMINATED NODE   READINESS GATES
nginx-pod   1/1     Running   0          13s   10.244.0.5   devops-cluster-control-plane   <none>           <none>
```

Wait until the STATUS shows `Running`. Then explore:
```bash
# Detailed info about the pod
kubectl describe pod nginx-pod

Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  65s   default-scheduler  Successfully assigned default/nginx-pod to devops-cluster-control-plane
  Normal  Pulling    65s   kubelet            spec.containers{nginx}: Pulling image "nginx:latest"
  Normal  Pulled     58s   kubelet            spec.containers{nginx}: Successfully pulled image "nginx:latest" in 6.771s (6.771s including waiting). Image size: 63422407 bytes.
  Normal  Created    58s   kubelet            spec.containers{nginx}: Container created
  Normal  Started    58s   kubelet            spec.containers{nginx}: Container started

```
```bash
# Read the logs
kubectl logs nginx-pod

/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2026/10/05 16:48:49 [notice] 1#1: using the "epoll" event method
2026/10/05 16:48:49 [notice] 1#1: nginx/1.31.6
2026/10/05 16:48:49 [notice] 1#1: built by gcc 14.2.0 (Debian 14.2.0-19) 
2026/10/05 16:48:49 [notice] 1#1: OS: Linux 6.17.0-1022-azure
2026/10/05 16:48:49 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1073741816:1073741816
2026/10/05 16:48:49 [notice] 1#1: start worker processes
2026/10/05 16:48:49 [notice] 1#1: start worker process 36
2026/10/05 16:48:49 [notice] 1#1: start worker process 37
```
```bash
# Get a shell inside the container
kubectl exec -it nginx-pod -- /bin/bash

# Inside the container, run:
curl localhost:80
exit

azureuser@Tws-lab:~$ kubectl exec -it nginx-pod -- /bin/bash
root@nginx-pod:/# curl localhost:80
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
```

**Verify:** Can you see the Nginx welcome page when you curl from inside the pod? -> Yes

---

### Task 2: Create a Custom Pod (BusyBox)
Write a new manifest `busybox-pod.yaml` from scratch (do not copy-paste the nginx one):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command: ["sh", "-c", "echo Hello from BusyBox && sleep 3600"]
```

Apply and verify:
```bash
kubectl apply -f busybox-pod.yaml
kubectl get pods
kubectl logs busybox-pod
```
```sh
azureuser@Tws-lab:~$ kubectl logs busybox-pod
Hello from BusyBox
```

Notice the `command` field — BusyBox does not run a long-lived server like Nginx. Without a command that keeps it running, the container would exit immediately and the pod would go into `CrashLoopBackOff`.

```bash
  Normal   Started    15s (x5 over 119s)  kubelet            spec.containers{busybox2}: Container started
  Normal   Pulled     15s                 kubelet            spec.containers{busybox2}: Successfully pulled image "busybox:latest" in 1.956s (1.956s including waiting). Image size: 2236767 bytes.
  Warning  BackOff    14s (x4 over 115s)  kubelet            spec.containers{busybox2}: Back-off restarting failed container busybox2 in pod busybox-pod2_default(3bc33d2c-4abb-4cee-9ac3-d97bc8cc7047)

azureuser@Tws-lab:~$ kubectl get pods
NAME           READY   STATUS      RESTARTS       AGE
busybox-pod    1/1     Running     0              10m
busybox-pod2   0/1     Completed   4 (117s ago)   2m45s

```

**Verify:** Can you see "Hello from BusyBox" in the logs? - Yes

---

### Task 3: Imperative vs Declarative
You have been using the declarative approach (writing YAML, then `kubectl apply`). Kubernetes also supports imperative commands:

```bash
# Create a pod without a YAML file
kubectl run redis-pod --image=redis:latest

# Check it
kubectl get pods

azureuser@Tws-lab:~$ kubectl run redis-pod --image=redis:latest
pod/redis-pod created
azureuser@Tws-lab:~$ kubectl get pods
NAME          READY   STATUS    RESTARTS   AGE
redis-pod     1/1     Running   0          8s
```

Now extract the YAML that Kubernetes generated:
```bash
kubectl get pod redis-pod -o yaml
```

Compare this output with your hand-written manifests. Notice how much extra metadata Kubernetes adds automatically (status, timestamps, uid, resource version).

You can also use dry-run to generate YAML without creating anything:
```bash
kubectl run test-pod --image=nginx --dry-run=client -o yaml
```

This is a powerful trick — use it to quickly scaffold a manifest, then customize it.

**Verify:** Save the dry-run output to a file and compare its structure with your nginx-pod.yaml. What fields are the same? What is different?

---

### Task 4: Validate Before Applying
Before applying a manifest, you can validate it:

```bash
# Check if the YAML is valid without actually creating the resource
kubectl apply -f nginx-pod.yaml --dry-run=client

azureuser@Tws-lab:~$ kubectl apply -f nginx-pod.yml --dry-run=client
pod/nginx-pod unchanged (dry run)

# Validate against the cluster's API (server-side validation)
kubectl apply -f nginx-pod.yaml --dry-run=server

azureuser@Tws-lab:~$ kubectl apply -f nginx-pod.yml --dry-run=server
pod/nginx-pod unchanged (server dry run)

```

Now intentionally break your YAML (remove the `image` field or add an invalid field) and run dry-run again. See what error you get.

**Verify:** What error does Kubernetes give when the image field is missing?

```bash
azureuser@Tws-lab:~$ kubectl apply -f nginx-pod.yml --dry-run=client
pod/nginx-pod configured (dry run)
azureuser@Tws-lab:~$ kubectl apply -f nginx-pod.yml --dry-run=server
The request is invalid: patch: Invalid value: "map[metadata:map[annotations:map[kubectl.kubernetes.io/last-applied-configuration:{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{},\"labels\":{\"app\":\"nginx\"},\"name\":\"nginx-pod\",\"namespace\":\"default\"},\"spec\":{\"containers\":[{\"mage\":\"nginx:latest\",\"name\":\"nginx\",\"ports\":[{\"containerPort\":80}]}]}}\n]] spec:map[]]": strict decoding error: unknown field "spec.containers[0].mage"
```
### Client-side dry run
Flag: --dry-run=client

What it does:
- Validates the manifest locally on your machine.
- Does not contact the Kubernetes API server.
- Useful for syntax checking and generating YAML without affecting the cluster.
> kubectl create configmap my-config --from-literal=key=value --dry-run=client -o yaml

Example Output:
Prints the YAML for the deployment without creating it.

### Server-side dry run
Flag: --dry-run=server

What it does:
- Sends the request to the API server for validation.
- The server runs admission controllers and checks if the request would succeed.
- No resources are actually created or modified.

Useful for:
- Validating against cluster policies, CRDs, and admission webhooks.
- Ensuring the manifest is valid in the current cluster context.
> kubectl apply -f my-deployment.yaml --dry-run=server

---

### Task 5: Pod Labels and Filtering
Labels are how Kubernetes organizes and selects resources. You added labels in your manifests — now use them:

```bash
# List all pods with their labels
kubectl get pods --show-labels

azureuser@Tws-lab:~$ kubectl get pods --show-labels
NAME          READY   STATUS    RESTARTS   AGE   LABELS
busybox-pod   1/1     Running   0          23m   app=busybox,environment=dev
nginx-pod     1/1     Running   0          31m   app=nginx
redis-pod     1/1     Running   0          11m   run=redis-pod

# Filter pods by label
kubectl get pods -l app=nginx
kubectl get pods -l environment=dev

# Add a label to an existing pod
kubectl label pod nginx-pod environment=production

# Verify
kubectl get pods --show-labels

azureuser@Tws-lab:~$ kubectl label pod nginx-pod environment=production
pod/nginx-pod labeled
azureuser@Tws-lab:~$ kubectl get pods --show-labels
NAME          READY   STATUS    RESTARTS   AGE   LABELS
busybox-pod   1/1     Running   0          24m   app=busybox,environment=dev
nginx-pod     1/1     Running   0          32m   app=nginx,environment=production

# Remove a label
kubectl label pod nginx-pod environment-

azureuser@Tws-lab:~$ kubectl label pod nginx-pod environment-
pod/nginx-pod unlabeled

```

Write a manifest for a third pod with at least 3 labels (app, environment, team). Apply it and practice filtering.

---

### Task 6: Clean Up
Delete all the pods you created:

```bash
# Delete by name
kubectl delete pod nginx-pod
kubectl delete pod busybox-pod
kubectl delete pod redis-pod

azureuser@Tws-lab:~$ kubectl delete pod --all
pod "busybox-pod" deleted from default namespace
pod "nginx-pod" deleted from default namespace
pod "redis-pod" deleted from default namespace

# Or delete using the manifest file
kubectl delete -f nginx-pod.yaml

# Verify everything is gone
kubectl get pods

azureuser@Tws-lab:~$ kubectl get pods
No resources found in default namespace.
```

Notice that when you delete a standalone Pod, it is gone forever. There is no controller to recreate it. This is why in production you use Deployments (coming on Day 52) instead of bare Pods.