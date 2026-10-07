# Day 52 – Kubernetes Namespaces and Deployments

## Challenge Tasks

### Task 1: Explore Default Namespaces
Kubernetes comes with built-in namespaces. List them:

```bash
kubectl get namespaces
azureuser@Tws-lab:~$ kubectl get ns
NAME                 STATUS   AGE
default              Active   25h
kube-node-lease      Active   25h
kube-public          Active   25h
kube-system          Active   25h
local-path-storage   Active   25h
```

You should see at least:
- `default` — where your resources go if you do not specify a namespace
- `kube-system` — Kubernetes internal components (API server, scheduler, etc.)
- `kube-public` — publicly readable resources
- `kube-node-lease` — node heartbeat tracking

Check what is running inside `kube-system`:
```bash
kubectl get pods -n kube-system
azureuser@Tws-lab:~$ kubectl get pods -n kube-system
NAME                                                   READY   STATUS    RESTARTS      AGE
coredns-559f6c778d-2v9kr                               1/1     Running   1 (93m ago)   25h
coredns-559f6c778d-rh7wg                               1/1     Running   1 (93m ago)   25h
etcd-devops-cluster-control-plane                      1/1     Running   1 (93m ago)   25h
kindnet-jsjs4                                          1/1     Running   1 (93m ago)   25h
kube-apiserver-devops-cluster-control-plane            1/1     Running   1 (93m ago)   25h
kube-controller-manager-devops-cluster-control-plane   1/1     Running   1 (93m ago)   25h
kube-proxy-sgjlp                                       1/1     Running   1 (93m ago)   25h
kube-scheduler-devops-cluster-control-plane            1/1     Running   1 (93m ago)   25h
```

These are the control plane components keeping your cluster alive. Do not touch them.

**Verify:** How many pods are running in `kube-system`? -> 8

---

### Task 2: Create and Use Custom Namespaces
Create two namespaces — one for a development environment and one for staging:

```bash
kubectl create namespace dev
kubectl create namespace staging
```

Verify they exist:
```bash
kubectl get namespaces
```

You can also create a namespace from a manifest:
```yaml
# namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production
```

```bash
kubectl apply -f namespace.yaml
```

Now run a pod in a specific namespace:
```bash
kubectl run nginx-dev --image=nginx:latest -n dev
kubectl run nginx-staging --image=nginx:latest -n staging

azureuser@Tws-lab:~$ kubectl run nginx-dev --image=nginx:latest -n dev
pod/nginx-dev created
azureuser@Tws-lab:~$ kubectl run nginx-staging --image=nginx:latyest -n staging
pod/nginx-staging created
```

List pods across all namespaces:
```bash
kubectl get pods -A
```

Notice that `kubectl get pods` without `-n` only shows the `default` namespace. You must specify `-n <namespace>` or use `-A` to see everything.

**Verify:** Does `kubectl get pods` show these pods? What about `kubectl get pods -A`?

```bash
azureuser@Tws-lab:~$ kubectl get pods
No resources found in default namespace.

azureuser@Tws-lab:~$ kubectl get pods -A
NAMESPACE            NAME                                                   READY   STATUS         RESTARTS      AGE
dev                  nginx-dev                                              1/1     Running        0             37s
kube-system          coredns-559f6c778d-2v9kr                               1/1     Running        1 (97m ago)   25h
kube-system          coredns-559f6c778d-rh7wg                               1/1     Running        1 (97m ago)   25h
kube-system          etcd-devops-cluster-control-plane                      1/1     Running        1 (97m ago)   25h
kube-system          kindnet-jsjs4                                          1/1     Running        1 (97m ago)   25h
kube-system          kube-apiserver-devops-cluster-control-plane            1/1     Running        1 (97m ago)   25h
kube-system          kube-controller-manager-devops-cluster-control-plane   1/1     Running        1 (97m ago)   25h
kube-system          kube-proxy-sgjlp                                       1/1     Running        1 (97m ago)   25h
kube-system          kube-scheduler-devops-cluster-control-plane            1/1     Running        1 (97m ago)   25h
local-path-storage   local-path-provisioner-75f7fc7dc5-jx4zf                1/1     Running        2 (96m ago)   25h
staging              nginx-staging                                          0/1     ErrImagePull   0             13s
```

---

### Task 3: Create Your First Deployment
A Deployment tells Kubernetes: "I want X replicas of this Pod running at all times." If a Pod crashes, the Deployment controller recreates it automatically.

Create a file `nginx-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.24
        ports:
        - containerPort: 80
```

Key differences from a standalone Pod:
- `kind: Deployment` instead of `kind: Pod`
- `apiVersion: apps/v1` instead of `v1`
- `replicas: 3` tells Kubernetes to maintain 3 identical pods
- `selector.matchLabels` connects the Deployment to its Pods
- `template` is the Pod template — the Deployment creates Pods using this blueprint

Apply it:
```bash
kubectl apply -f nginx-deployment.yaml
```

Check the result:
```bash
kubectl get deployments -n dev
kubectl get pods -n dev

azureuser@Tws-lab:~$ kubectl apply -f nginx-deployment.yaml 
deployment.apps/nginx-deployment created
azureuser@Tws-lab:~$ kubectl get deployments -n dev
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           11s
azureuser@Tws-lab:~$ kubectl get po -n dev
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-7f5f95d8d-2cbbp   1/1     Running   0          31s
nginx-deployment-7f5f95d8d-h24f4   1/1     Running   0          31s
nginx-dev                          1/1     Running   0          5m45s
```

You should see 3 pods with names like `nginx-deployment-xxxxx-yyyyy`.

**Verify:** What do the READY, UP-TO-DATE, and AVAILABLE columns mean in the deployment output?

- READY displays how many replicas of the application are available to your users. It follows the pattern ready/desired.
- UP-TO-DATE displays the number of replicas that have been updated to achieve the desired state.
- AVAILABLE displays how many replicas of the application are available to your users.

---

### Task 4: Self-Healing — Delete a Pod and Watch It Come Back
This is the key difference between a Deployment and a standalone Pod.

```bash
# List pods
kubectl get pods -n dev

# Delete one of the deployment's pods (use an actual pod name from your output)
kubectl delete pod <pod-name> -n dev

# Immediately check again
kubectl get pods -n dev

azureuser@Tws-lab:~$ kubectl get pods -n dev
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-7f5f95d8d-2cbbp   1/1     Running   0          7m58s
nginx-deployment-7f5f95d8d-h24f4   1/1     Running   0          7m58s
nginx-dev                          1/1     Running   0          13m

azureuser@Tws-lab:~$ kubectl delete pod nginx-deployment-7f5f95d8d-2cbbp -n dev
pod "nginx-deployment-7f5f95d8d-2cbbp" deleted from dev namespace

azureuser@Tws-lab:~$ kubectl get pods -n dev
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-7f5f95d8d-5llvs   1/1     Running   0          4s
nginx-deployment-7f5f95d8d-h24f4   1/1     Running   0          9m3s
nginx-dev                          1/1     Running   0          14m
```

The Deployment controller detects that only 2 of 3 desired replicas exist and immediately creates a new one. The deleted pod is replaced within seconds.

**Verify:** Is the replacement pod's name the same as the one you deleted, or different? - It is bit different

---

### Task 5: Scale the Deployment
Change the number of replicas:

```bash
# Scale up to 5
kubectl scale deployment nginx-deployment --replicas=5 -n dev
kubectl get pods -n dev

azureuser@Tws-lab:~$ kubectl scale deployment nginx-deployment --replicas=3 -n dev
deployment.apps/nginx-deployment scaled
azureuser@Tws-lab:~$ kubectl get all -n dev
NAME                                   READY   STATUS    RESTARTS      AGE
pod/nginx-deployment-7f5f95d8d-5llvs   1/1     Running   1 (22m ago)   11h
pod/nginx-deployment-7f5f95d8d-h24f4   1/1     Running   1 (22m ago)   11h
pod/nginx-deployment-7f5f95d8d-t86kg   1/1     Running   0             8s

# Scale down to 2
kubectl scale deployment nginx-deployment --replicas=2 -n dev
kubectl get pods -n dev

azureuser@Tws-lab:~$ kubectl scale deployment nginx-deployment --replicas=2 -n dev
deployment.apps/nginx-deployment scaled
azureuser@Tws-lab:~$ kubectl get pods -n dev
NAME                               READY   STATUS    RESTARTS      AGE
nginx-deployment-7f5f95d8d-5llvs   1/1     Running   1 (22m ago)   11h
nginx-deployment-7f5f95d8d-h24f4   1/1     Running   1 (22m ago)   11h
```

Watch how Kubernetes creates or terminates pods to match the desired count.

You can also scale by editing the manifest — change `replicas: 4` in your YAML file and run `kubectl apply -f nginx-deployment.yaml` again.

**Verify:** When you scaled down from 5 to 2, what happened to the extra pods? -> Deleted

---

### Task 6: Rolling Update
Update the Nginx image version to trigger a rolling update:

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev

azureuser@Tws-lab:~$ kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
deployment.apps/nginx-deployment image updated
azureuser@Tws-lab:~$ kubectl get pods -n dev
NAME                                READY   STATUS              RESTARTS      AGE
nginx-deployment-6946987795-n8fhk   0/1     ContainerCreating   0             8s
nginx-deployment-7f5f95d8d-5llvs    1/1     Running             1 (25m ago)   11h
nginx-deployment-7f5f95d8d-h24f4    1/1     Running             1 (25m ago)   11h
```

Watch the rollout in real time:
```bash
kubectl rollout status deployment/nginx-deployment -n dev

azureuser@Tws-lab:~$ kubectl rollout status deployment/nginx-deployment -n dev
deployment "nginx-deployment" successfully rolled out
azureuser@Tws-lab:~$ kubectl get pods -n dev
NAME                                READY   STATUS    RESTARTS      AGE
nginx-deployment-6946987795-7nnh9   1/1     Running   0             22s
nginx-deployment-6946987795-n8fhk   1/1     Running   0             31s
```

Kubernetes replaces pods one by one — old pods are terminated only after new ones are healthy. This means zero downtime.

Check the rollout history:
```bash
kubectl rollout history deployment/nginx-deployment -n dev

azureuser@Tws-lab:~$ kubectl rollout history deployment/nginx-deployment -n dev
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

Now roll back to the previous version:
```bash
kubectl rollout undo deployment/nginx-deployment -n dev

azureuser@Tws-lab:~$ kubectl rollout undo deployment/nginx-deployment -n dev
Warning: resource deployments/nginx-deployment was previously managed with 'kubectl apply'. Rolling back will not update the kubectl.kubernetes.io/last-applied-configuration annotation, which may cause unexpected behavior on future 'kubectl apply' operations. Consider using 'kubectl apply' with your previous configuration file instead.
deployment.apps/nginx-deployment rolled back

kubectl rollout status deployment/nginx-deployment -n dev

azureuser@Tws-lab:~$ kubectl rollout status deployment/nginx-deployment -n dev
deployment "nginx-deployment" successfully rolled out
azureuser@Tws-lab:~$ kubectl rollout history deployment/nginx-deployment -n dev
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
```

Verify the image is back to the previous version:
```bash
kubectl describe deployment nginx-deployment -n dev | grep Image

azureuser@Tws-lab:~$ kubectl describe deployment nginx-deployment -n dev | grep Image
    Image:         nginx:1.24
```

**Verify:** What image version is running after the rollback? - nginx:1.24

---

### Task 7: Clean Up
```bash
kubectl delete deployment nginx-deployment -n dev
kubectl delete pod nginx-dev -n dev
kubectl delete pod nginx-staging -n staging
kubectl delete namespace dev staging production
```

Deleting a namespace removes everything inside it. Be very careful with this in production.

```bash
kubectl get namespaces
kubectl get pods -A
```

**Verify:** Are all your resources gone? -> Resource which I created are gone, default ones still exist.