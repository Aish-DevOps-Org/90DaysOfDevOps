# Day 58 – Metrics Server and Horizontal Pod Autoscaler (HPA)

**Metrics Server:** collects resource usage metrics from Kubernetes nodes and Pods, mainly: CPU usage and Memory usage \
Once installed, it enables commands such as: kubectl top nodes/pods

So Metrics Server provides the metrics that HPA can use for resource-based scaling.

**HPA:** It automatically changes the number of Pod replicas based on observed metrics.

### Task 1: Install the Metrics Server
1. Check if it is already running: `kubectl get pods -n kube-system | grep metrics-server`
2. If not, install it:
   - Minikube: `minikube addons enable metrics-server`
   - Kind/kubeadm: apply the official manifest from the metrics-server GitHub releases

```sh
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

#Because KinD operates inside Docker containers with self-signed node certificates, you need to append the --kubelet-insecure-tls flag to the deployment arguments.
#Run this command to patch the deployment directly:
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[
  {"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}
]'

azureuser@Tws-lab:~$ kubectl get pods -n kube-system -w | grep metrics-serve
metrics-server-84c99cb944-hdx4n                        1/1     Running   0               2m25s

```
3. On local clusters, you may need the `--kubelet-insecure-tls` flag (never in production)
4. Wait 60 seconds, then verify: `kubectl top nodes` and `kubectl top pods -A`
```sh
azureuser@Tws-lab:~$ kubectl top nodes
NAME                           CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
devops-cluster-control-plane   79m          3%       1399Mi          17%
azureuser@Tws-lab:~$ kubectl top pods -A
NAMESPACE            NAME                                                   CPU(cores)   MEMORY(bytes)
kube-system          coredns-559f6c778d-2v9kr                               1m           88Mi
kube-system          coredns-559f6c778d-rh7wg                               1m           16Mi
kube-system          etcd-devops-cluster-control-plane                      11m          85Mi
kube-system          kindnet-jsjs4                                          1m           82Mi
kube-system          kube-apiserver-devops-cluster-control-plane            20m          330Mi
kube-system          kube-controller-manager-devops-cluster-control-plane   9m           141Mi
kube-system          kube-proxy-sgjlp                                       1m           70Mi
kube-system          kube-scheduler-devops-cluster-control-plane            5m           75Mi
kube-system          metrics-server-84c99cb944-hdx4n                        2m           20Mi
local-path-storage   local-path-provisioner-75f7fc7dc5-jx4zf                1m           10Mi
```
**Verify:** What is the current CPU and memory usage of your node? -> 3% CPU and 17% memory

---

### Task 2: Explore kubectl top
1. Run `kubectl top nodes`, `kubectl top pods -A`, `kubectl top pods -A --sort-by=cpu`
2. `kubectl top` shows real-time usage, not requests or limits — these are different things
3. Data comes from the Metrics Server, which polls kubelets every 15 seconds

**Verify:** Which pod is using the most CPU right now?
```sh
azureuser@Tws-lab:~$ kubectl top pods -A --sort-by=cpu
NAMESPACE            NAME                                                   CPU(cores)   MEMORY(bytes)
kube-system          kube-apiserver-devops-cluster-control-plane            20m          330Mi
```
---

### Task 3: Create a Deployment with CPU Requests
1. Write a Deployment manifest using the `registry.k8s.io/hpa-example` image (a CPU-intensive PHP-Apache server)
[k8s official - HPA manifest](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/#run-and-expose-php-apache-server)
```sh
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: hpa-example
        image: registry.k8s.io/hpa-example
        ports:
          - containerPort: 80
        resources:
          requests:
            cpu: 200m
          limits:
            cpu: 500m
```
2. Set `resources.requests.cpu: 200m` — HPA needs this to calculate utilization percentages
3. Expose it as a Service: `kubectl expose deployment php-apache --port=80`
```sh
azureuser@Tws-lab:~$ kubectl apply -f deployment-hpa.yaml
deployment.apps/php-apache created
azureuser@Tws-lab:~$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   0/1     1            0           10s
azureuser@Tws-lab:~$ kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
php-apache-859c9b6fcd-dtgmf   1/1     Running   0          19s
azureuser@Tws-lab:~$ kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   1/1     1            1           23s
azureuser@Tws-lab:~$ kubectl expose deployment php-apache --port=80
service/php-apache exposed
azureuser@Tws-lab:~$ kubectl get svc
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1      <none>        443/TCP   5d
php-apache   ClusterIP   10.96.192.18   <none>        80/TCP    8s
azureuser@Tws-lab:~$ kubectl get endpoints php-apache
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME         ENDPOINTS        AGE
php-apache   10.244.0.16:80   31s
azureuser@Tws-lab:~$ kubectl get po -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE                           NOMINATED NODE   READINESS GATES
php-apache-859c9b6fcd-dtgmf   1/1     Running   0          81s   10.244.0.16   devops-cluster-control-plane   <none>           <none>
```

Without CPU requests, HPA cannot work — this is the most common HPA setup mistake.

**Verify:** What is the current CPU usage of the Pod?
```sh
azureuser@Tws-lab:~$ kubectl top nodes
NAME                           CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
devops-cluster-control-plane   84m          4%       1550Mi          19%
azureuser@Tws-lab:~$ kubectl top pods
NAME                          CPU(cores)   MEMORY(bytes)
php-apache-859c9b6fcd-dtgmf   1m           9Mi
```

---

### Task 4: Create an HPA (Imperative)
1. Run: `kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10`
2. Check: `kubectl get hpa` and `kubectl describe hpa php-apache`
```sh
azureuser@Tws-lab:~$ kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
Flag --cpu-percent has been deprecated, Use --cpu with percentage or resource quantity format (e.g., '70%' for utilization or '500m' for milliCPU).
horizontalpodautoscaler.autoscaling/php-apache autoscaled
azureuser@Tws-lab:~$ kubectl get hpa
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 0%/50%   1         10        1          14s

```
3. TARGETS may show `<unknown>` initially — wait 30 seconds for metrics to arrive

This scales up when average CPU exceeds 50% of requests, and down when it drops below.

**Verify:** What does the TARGETS column show? -> cpu: 0%/50%

---

### Task 5: Generate Load and Watch Autoscaling
1. Start a load generator: `kubectl run load-generator --image=busybox:1.36 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"`
> This script generates load by creating an infinite loop that floods the target server with continuous HTTP requests as fast as the network and CPU can process them.

The wget http://php-apache command forces the container to:\
• Look up the IP address of php-apache via Kubernetes DNS.\
• Establish a new TCP connection with the target server.\
• Complete an HTTP request and download the response.\
• Close the connection.\
Doing this thousands of times per minute consumes significant CPU cycles and network bandwidth on both the load-generator pod and the target php-apache server.

```sh
azureuser@Tws-lab:~$ kubectl top nodes
NAME                           CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)
devops-cluster-control-plane   605m         30%      1544Mi          19%
azureuser@Tws-lab:~$ kubectl top pods
NAME                          CPU(cores)   MEMORY(bytes)
load-generator                14m          0Mi
php-apache-859c9b6fcd-dtgmf   340m         12Mi
php-apache-859c9b6fcd-njxtt   202m         12Mi
php-apache-859c9b6fcd-rmrmh   239m         11Mi
php-apache-859c9b6fcd-wwg5c   127m         11Mi
azureuser@Tws-lab:~$ kubectl get poi
error: the server doesn't have a resource type "poi"
azureuser@Tws-lab:~$ kubectl get po
NAME                          READY   STATUS    RESTARTS   AGE
load-generator                1/1     Running   0          67s
php-apache-859c9b6fcd-c2zlc   0/1     Pending   0          18s
php-apache-859c9b6fcd-dtgmf   1/1     Running   0          6m39s
php-apache-859c9b6fcd-j28b5   0/1     Pending   0          18s
php-apache-859c9b6fcd-njxtt   1/1     Running   0          33s
php-apache-859c9b6fcd-rmrmh   1/1     Running   0          33s
php-apache-859c9b6fcd-s7rtk   0/1     Pending   0          18s
php-apache-859c9b6fcd-s8s47   0/1     Pending   0          18s
php-apache-859c9b6fcd-wwg5c   1/1     Running   0          33s
```
2. Watch HPA: `kubectl get hpa php-apache --watch`
```sh
azureuser@Tws-lab:~$ kubectl get hpa php-apache --watch
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 0%/50%   1         10        1          2m36s
php-apache   Deployment/php-apache   cpu: 247%/50%   1         10        1          2m45s
php-apache   Deployment/php-apache   cpu: 117%/50%   1         10        4          3m
php-apache   Deployment/php-apache   cpu: 88%/50%    1         10        8          3m15s
php-apache   Deployment/php-apache   cpu: 76%/50%    1         10        8          3m30s
php-apache   Deployment/php-apache   cpu: 81%/50%    1         10        8          3m45s
php-apache   Deployment/php-apache   cpu: 77%/50%    1         10        8          4m
php-apache   Deployment/php-apache   cpu: 82%/50%    1         10        8          4m15s
php-apache   Deployment/php-apache   cpu: 80%/50%    1         10        8          4m30s
php-apache   Deployment/php-apache   cpu: 79%/50%    1         10        8          4m45s
php-apache   Deployment/php-apache   cpu: 74%/50%    1         10        8          5m
```
3. Over 1-3 minutes, CPU climbs above 50%, replicas increase, CPU stabilizes
4. Stop the load: `kubectl delete pod load-generator`
```sh
azureuser@Tws-lab:~kubectl delete pod load-generatoror
pod "load-generator" deleted from default namespace
azureuser@Tws-lab:~$ kubectl get hpa php-apache --watch
NAME         REFERENCE               TARGETS        MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 80%/50%   1         10        8          5m47s
php-apache   Deployment/php-apache   cpu: 30%/50%   1         10        8          6m
php-apache   Deployment/php-apache   cpu: 14%/50%   1         10        8          6m15s
php-apache   Deployment/php-apache   cpu: 0%/50%    1         10        8          6m30s
php-apache   Deployment/php-apache   cpu: 0%/50%    1         10        8          10m
php-apache   Deployment/php-apache   cpu: 0%/50%    1         10        3          11m
php-apache   Deployment/php-apache   cpu: 0%/50%    1         10        2          11m
```
5. Scale-down is slow (5-minute stabilization window) — you do not need to wait

**Verify:** How many replicas did HPA scale to under load? -> 8

---

### Task 6: Create an HPA from YAML (Declarative)
1. Delete the imperative HPA: `kubectl delete hpa php-apache`
> horizontalpodautoscaler.autoscaling "php-apache" deleted from default namespace
2. Write an HPA manifest using `autoscaling/v2` API with CPU target at 50% utilization
3. Add a `behavior` section to control scale-up speed (no stabilization) and scale-down speed (300 second window)
```sh
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50

# --- CUSTOM SCALING BEHAVIOR BLOCK ---
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 4
        periodSeconds: 15
      selectPolicy: Max
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      selectPolicy: Min
```
If your deployment currently has 1 pod and traffic suddenly spikes:
- The Percent: 100 policy calculates: Add 100% of 1 pod = 1 new pod.
- The Pods: 4 policy calculates: Add 4 new pods.
- Because selectPolicy is set to Max, Kubernetes picks the larger number (4) and immediately provisions 4 new pods, bringing your total to 5 pods within 15 seconds.

4. Apply and verify with `kubectl describe hpa`
```sh
azureuser@Tws-lab:~$ kubectl apply -f hpa.yaml
horizontalpodautoscaler.autoscaling/php-apache created

azureuser@Tws-lab:~$ kubectl get hpa
NAME         REFERENCE               TARGETS       MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   cpu: 0%/50%   1         10        1          12s
```
`autoscaling/v2` supports multiple metrics and fine-grained scaling behavior that the imperative command cannot configure.

**Verify:** What does the `behavior` section control?
> Configure specific scaling behaviors (like slowing down scale-down or speeding up scale-up) by adding a behavior block
```sh
Behavior:
  Scale Up:
    Stabilization Window: 0 seconds
    Select Policy: Max
    Policies:
      - Type: Percent  Value: 100  Period: 15 seconds
      - Type: Pods     Value: 4    Period: 15 seconds
  Scale Down:
    Stabilization Window: 300 seconds
    Select Policy: Min
    Policies:
      - Type: Percent  Value: 100  Period: 15 seconds
```
---

### Task 7: Clean Up
Delete the HPA, Service, Deployment, and load-generator pod. Leave the Metrics Server installed.

---

## Hints
- HPA requires `resources.requests` — without them TARGETS shows `<unknown>`
- `kubectl top` = actual usage. `kubectl describe pod` = configured requests/limits
- HPA checks every 15 seconds. Scale-up is fast, scale-down has a 5-minute stabilization window
- `autoscaling/v1` = CPU only. `autoscaling/v2` = CPU + memory + custom metrics
- Formula: `desiredReplicas = ceil(currentReplicas * (currentUsage / targetUsage))`
- HPA works with Deployments, StatefulSets, and ReplicaSets

```
ReplicaSet = maintain N identical Pods
Deployment = manage ReplicaSets and perform application updates
StatefulSet = manage Pods that need stable identity/storage

Deployment
    ↓
ReplicaSet
    ↓
 ┌──┴───┐
Pod    Pod    Pod
```

| Feature                      | Deployment   | ReplicaSet                 | StatefulSet             |
| ---------------------------- | ------------ | -------------------------- | ----------------------- |
| Keeps desired number of Pods | ✅            | ✅                          | ✅                       |
| Rolling updates              | ✅            | ❌ Not its main purpose     | ✅                       |
| Rollback support             | ✅            | ❌                          | ✅                       |
| Stable Pod names             | ❌            | ❌                          | ✅                       |
| Stable storage per Pod       | ❌            | ❌                          | ✅                       |
| Typical use                  | Web/API apps | Underlying Pod replication | Databases/stateful apps |
| Usually create directly?     | ✅ Yes        | ❌ Usually no               | ✅ Yes                   |
