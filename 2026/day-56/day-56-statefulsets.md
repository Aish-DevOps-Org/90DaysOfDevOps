# Day 56 – Kubernetes StatefulSets

### Task 1: Understand the Problem
1. Create a Deployment with 3 replicas using nginx
2. Check the pod names — they are random (`app-xyz-abc`)
3. Delete a pod and notice the replacement gets a different random name

This is fine for web servers but not for databases where you need stable identity.

| Feature | Deployment | StatefulSet |
|---|---|---|
| Pod names | Random | Stable, ordered (`app-0`, `app-1`) |
| Startup order | All at once | Ordered: pod-0, then pod-1, then pod-2 |
| Storage | Shared PVC | Each pod gets its own PVC |
| Network identity | No stable hostname | Stable DNS per pod |
```sh
azureuser@Tws-lab:~$ kubectl apply -f app-deployment.yaml 
deployment.apps/web-app created
azureuser@Tws-lab:~$ kubectl get po
NAME                       READY   STATUS    RESTARTS   AGE
web-app-56b5ddf4c5-b7lc9   1/1     Running   0          4s
web-app-56b5ddf4c5-vnmfb   1/1     Running   0          4s
web-app-56b5ddf4c5-xsv49   1/1     Running   0          4s
```
Delete the Deployment before moving on.

**Verify:** Why would random pod names be a problem for a database cluster? - if one pod goes down and anothert comes up, we cannot guess what will be the name of that pod so connectivity can be a problem.
And because they destroy identity, data continuity, and peer discovery.

---

### Task 2: Create a Headless Service
1. Write a Service manifest with `clusterIP: None` — this is a Headless Service
```sh
apiVersion: v1
kind: Service
metadata:
  name: web-app-clusterip
spec:
  clusterIP: None
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
```
2. Set the selector to match the labels you will use on your StatefulSet pods
3. Apply it and confirm CLUSTER-IP shows `None`

A Headless Service creates individual DNS entries for each pod instead of load-balancing to one IP. StatefulSets require this.

**Verify:** What does the CLUSTER-IP column show? -> None
```sh
azureuser@Tws-lab:~$ kubectl apply -f clusterip-service.yaml 
service/web-app-clusterip created
azureuser@Tws-lab:~$ kubectl get svc
NAME                TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
web-app-clusterip   ClusterIP   None         <none>        80/TCP    6s
```
---

### Task 3: Create a StatefulSet
1. Write a StatefulSet manifest with `serviceName` pointing to your Headless Service
2. Set replicas to 3, use the nginx image
3. Add a `volumeClaimTemplates` section requesting 100Mi of ReadWriteOnce storage
```sh
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: web-set
spec:
  serviceName: "web-app-clusterip"
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  minReadySeconds: 10
  template:
    metadata:
      labels:
        app: web-app
    spec:
      terminationGracePeriodSeconds: 10
      containers:
        - name: nginx
          image: registry.k8s.io/nginx-slim:0.24
          ports:
            - containerPort: 80
              name: web
          volumeMounts:
          - name: www
            mountPath: /usr/share/nginx/html

  volumeClaimTemplates:
  - metadata:
      name: www
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 100Mi
```
4. Apply and watch: `kubectl get pods -l <your-label> -w`

If you already created the StatefulSet with a different `serviceName` or selector, delete and recreate it after correcting the manifest; those fields are immutable. Deleting the StatefulSet leaves its PVCs intact.

```sh
azureuser@Tws-lab:~$ vim statefulset.yaml 
azureuser@Tws-lab:~$ kubectl apply -f statefulset.yaml 
statefulset.apps/web-set created
azureuser@Tws-lab:~$ kubectl get pvc
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
www-web-set-0   Bound    pvc-65ad2233-1dd8-4b27-9487-5b1776dda5f1   100Mi      RWO            standard       <unset>                 7s
azureuser@Tws-lab:~$ kubectl get po -o wide
NAME        READY   STATUS              RESTARTS   AGE   IP            NODE                           NOMINATED NODE   READINESS GATES
web-set-0   1/1     Running             0          32s   10.244.0.15   devops-cluster-control-plane   <none>           <none>
web-set-1   0/1     ContainerCreating   0          5s    <none>        devops-cluster-control-plane   <none>           <none>
```

Observe ordered creation — `web-set-0` first, then `web-set-1` after `web-set-0` is Ready, then `web-set-2`.

Check the PVCs: `kubectl get pvc` — with the manifest above, you should see `www-web-set-0`, `www-web-set-1`, and `www-web-set-2` (names follow the pattern `<template-name>-<statefulset-name>-<ordinal>`).

```sh
azureuser@Tws-lab:~$ kubectl get pvc
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
www-web-set-0   Bound    pvc-65ad2233-1dd8-4b27-9487-5b1776dda5f1   100Mi      RWO            standard       <unset>                 55s
www-web-set-1   Bound    pvc-a865f7d5-72a6-43be-ab10-bf85e7cf6a75   100Mi      RWO            standard       <unset>                 28s
www-web-set-2   Bound    pvc-b4a000e1-9999-4ae9-9fac-3598eb4814b9   100Mi      RWO            standard       <unset>                 13s
azureuser@Tws-lab:~$ kubectl get po -o wide
NAME        READY   STATUS    RESTARTS   AGE   IP            NODE                           NOMINATED NODE   READINESS GATES
web-set-0   1/1     Running   0          58s   10.244.0.15   devops-cluster-control-plane   <none>           <none>
web-set-1   1/1     Running   0          31s   10.244.0.17   devops-cluster-control-plane   <none>           <none>
web-set-2   1/1     Running   0          16s   10.244.0.19   devops-cluster-control-plane   <none>           <none>
```

**Verify:** What are the exact pod names and PVC names?

---

### Task 4: Stable Network Identity
Each StatefulSet pod gets a DNS name: `<pod-name>.<service-name>.<namespace>.svc.cluster.local`

Note: check which sevice is attached to statfulset
> kubectl get sts web-set -o jsonpath='{.spec.serviceName}{"\n"}'

1. Run a temporary busybox pod with `kubectl run busybox-temp --rm -it --restart=Never --image=busybox -- sh`, then use `nslookup` to resolve `web-set-0.web-app-clusterip.default.svc.cluster.local`

```sh
Name:   web-set-0.web-app-clusterip.default.svc.cluster.local
Address: 10.244.0.26
```

2. Do the same for `web-set-1` and `web-set-2`
```sh
Name:   web-set-1.web-app-clusterip.default.svc.cluster.local
Address: 10.244.0.27
Name:   web-set-2.web-app-clusterip.default.svc.cluster.local
Address: 10.244.0.28
```
3. Confirm the IPs match `kubectl get pods -o wide`
```sh
azureuser@Tws-lab:~$ kubectl get po -o wide
NAME        READY   STATUS    RESTARTS   AGE     IP            NODE                           NOMINATED NODE   READINESS GATES
web-set-0   1/1     Running   0          3m5s    10.244.0.26   devops-cluster-control-plane   <none>           <none>
web-set-1   1/1     Running   0          2m55s   10.244.0.27   devops-cluster-control-plane   <none>           <none>
web-set-2   1/1     Running   0          2m45s   10.244.0.28   devops-cluster-control-plane   <none>           <none>

azureuser@Tws-lab:~$ kubectl get endpoints web-app-clusterip
NAME                ENDPOINTS                                      AGE
web-app-clusterip   10.244.0.26:80,10.244.0.27:80,10.244.0.28:80   99m
```

**Verify:** Does the nslookup IP match the pod IP? -> yes

---

### Task 5: Stable Storage — Data Survives Pod Deletion
1. Write data to the pod: `kubectl exec web-set-0 -- sh -c "echo 'Data from web-set-0' > /usr/share/nginx/html/index.html"`
2. Delete `web-set-0`: `kubectl delete pod web-set-0`
3. Wait for it to come back, then check the data — it should still be "Data from web-set-0"

The new pod reconnected to the same PVC.

```sh
azureuser@Tws-lab:~$ kubectl exec web-set-0 -- sh -c "echo 'Data from web-set-0' > /usr/share/nginx/html/index.html"
azureuser@Tws-lab:~$ kubectl delete pod web-set-0
pod "web-set-0" deleted from default namespace
azureuser@Tws-lab:~$ kubectl get po
NAME        READY   STATUS    RESTARTS   AGE
web-set-0   1/1     Running   0          14s
...

azureuser@Tws-lab:~$ kubectl exec web-set-0 -- sh -c "cat /usr/share/nginx/html/index.html"
Data from web-set-0
```
**Verify:** Is the data identical after pod recreation? -> yes

---

### Task 6: Ordered Scaling
1. Scale up to 5: `kubectl scale statefulset web-set --replicas=5` — pods create in order (`web-set-3`, then `web-set-4`)
```sh
azureuser@Tws-lab:~$ kubectl get po
NAME        READY   STATUS    RESTARTS   AGE
web-set-0   1/1     Running   0          2m42s
web-set-1   1/1     Running   0          12m
web-set-2   1/1     Running   0          12m
web-set-3   1/1     Running   0          20s
web-set-4   1/1     Running   0          5s
```
2. Scale down to 3 — pods terminate in reverse order (`web-set-4`, then `web-set-3`)
```sh
azureuser@Tws-lab:~$ kubectl scale statefulset web-set --replicas=3
statefulset.apps/web-set scaled
azureuser@Tws-lab:~$ kubectl get po
NAME        READY   STATUS    RESTARTS   AGE
web-set-0   1/1     Running   0          3m16s
web-set-1   1/1     Running   0          12m
web-set-2   1/1     Running   0          12m
```
3. Check `kubectl get pvc` — all five PVCs still exist. Kubernetes keeps them on scale-down so data is preserved if you scale back up.
```sh
azureuser@Tws-lab:~$ kubectl get pvc
NAME            STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
www-web-set-0   Bound    pvc-65ad2233-1dd8-4b27-9487-5b1776dda5f1   100Mi      RWO            standard       <unset>                 42m
www-web-set-1   Bound    pvc-a865f7d5-72a6-43be-ab10-bf85e7cf6a75   100Mi      RWO            standard       <unset>                 42m
www-web-set-2   Bound    pvc-b4a000e1-9999-4ae9-9fac-3598eb4814b9   100Mi      RWO            standard       <unset>                 42m
www-web-set-3   Bound    pvc-7ea612d8-0838-483e-be8c-d3ec4b8302ba   100Mi      RWO            standard       <unset>                 81s
www-web-set-4   Bound    pvc-751b0f29-682a-47ec-83e5-cb78d51c1528   100Mi      RWO            standard       <unset>                 66s
```
**Verify:** After scaling down, how many PVCs exist? -> 5

---

### Task 7: Clean Up
1. Delete the StatefulSet and the Headless Service
2. Check `kubectl get pvc` — PVCs are still there (safety feature)
3. Delete PVCs manually

**Verify:** Were PVCs auto-deleted with the StatefulSet? -> no

---