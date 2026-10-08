# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

### Task 1: See the Problem — Data Lost on Pod Deletion
1. Write a Pod manifest that uses an `emptyDir` volume and writes a timestamped message to `/data/message.txt`
```bash
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command:
      - /bin/sh
      - -c
      - |
        echo "$(date)" >> /data/message.txt
        echo "$(cat /data/message.txt)"
        tail -f /dev/null                   # keeps container running
    volumeMounts:
    - name: storage
      mountPath: /data
  volumes:
  - name: storage
    emptyDir: {}
```
2. Apply it, verify the data exists with `kubectl exec`

```bash
azureuser@Tws-lab:~$ kubectl exec busybox -- cat /data/message.txt
Thu Oct  8 06:13:25 UTC 2026
```

3. Delete the Pod, recreate it, check the file again — the old message is gone

```bash
azureuser@Tws-lab:~$ kubectl get po
NAME      READY   STATUS        RESTARTS   AGE
busybox   1/1     Terminating   0          2m17s
azureuser@Tws-lab:~$ kubectl get po
No resources found in default namespace.
azureuser@Tws-lab:~$ kubectl apply -f redis-pod.yaml 
pod/busybox created
azureuser@Tws-lab:~$ kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          3s
azureuser@Tws-lab:~$ kubectl exec busybox -- cat /data/message.txt
Thu Oct  8 06:16:12 UTC 2026
azureuser@Tws-lab:~$ 

```

**Verify:** Is the timestamp the same or different after recreation? -> Different 

---

### Task 2: Create a PersistentVolume (Static Provisioning)
1. Write a PV manifest with `capacity: 1Gi`, `accessModes: ReadWriteOnce`, `persistentVolumeReclaimPolicy: Retain`, and `hostPath` pointing to `/tmp/k8s-pv-data`

```sh
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-vol
  labels:
    type: local
spec:
  storageClassName: manual
  capacity: 
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/k8s-pv-data
  persistentVolumeReclaimPolicy: Retain
```

2. Apply it and check `kubectl get pv` — status should be `Available`

```sh
azureuser@Tws-lab:~$ kubectl get pv pv-vol
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-vol   1Gi        RWO            Retain           Available           manual         <unset>                          25s
```

Access modes to know:
- `ReadWriteOnce (RWO)` — read-write by a single node
- `ReadOnlyMany (ROX)` — read-only by many nodes
- `ReadWriteMany (RWX)` — read-write by many nodes

`hostPath` is fine for learning, not for production.

**Verify:** What is the STATUS of the PV? -> Available

---

### Task 3: Create a PersistentVolumeClaim
1. Write a PVC manifest requesting `500Mi` of storage with `ReadWriteOnce` access

```sh

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-vol
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

2. Apply it and check both `kubectl get pvc` and `kubectl get pv`
```sh
azureuser@Tws-lab:~$ kubectl get pvc
NAME      STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-vol   Bound    pv-vol   1Gi        RWO            manual         <unset>                 6s

azureuser@Tws-lab:~$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-vol   1Gi        RWO            Retain           Bound    default/pvc-vol   manual         <unset>                          8m52s
```
3. Both should show `Bound` — Kubernetes matched them by capacity and access mode

**Verify:** What does the VOLUME column in `kubectl get pvc` show? -> pv-vol

---

### Task 4: Use the PVC in a Pod — Data That Survives
1. Write a Pod manifest that mounts the PVC at `/data` using `persistentVolumeClaim.claimName`
```bash
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: busybox
    image: busybox:latest
    command:
      - /bin/sh
      - -c
      - |
        echo "$(date)" >> /data/message.txt
        echo "$(cat /data/message.txt)"
        tail -f /dev/null
    volumeMounts:
    - name: pv-storage
      mountPath: "/data"
  volumes:
  - name: pv-storage
    persistentVolumeClaim:
      claimName: pvc-vol
```
2. Write data to `/data/message.txt`, then delete and recreate the Pod
```sh
azureuser@Tws-lab:~$ kubectl get po
No resources found in default namespace.
azureuser@Tws-lab:~$ kubectl apply -f redis-pod.yaml 
pod/busybox created
azureuser@Tws-lab:~$ kubectl get po
NAME      READY   STATUS    RESTARTS   AGE
busybox   1/1     Running   0          3s
azureuser@Tws-lab:~$ kubectl logs busybox
Thu Oct  8 16:53:09 UTC 2026
```
3. Check the file — it should contain data from both Pods
```sh
azureuser@Tws-lab:~$ kubectl delete pod busybox
pod "busybox" deleted from default namespace
azureuser@Tws-lab:~$ kubectl apply -f redis-pod.yaml 
pod/busybox created
azureuser@Tws-lab:~$ kubectl logs busybox
Thu Oct  8 16:53:09 UTC 2026
Thu Oct  8 16:58:07 UTC 2026
```
**Verify:** Does the file contain data from both the first and second Pod? -> yes

---

### Task 5: StorageClasses and Dynamic Provisioning
1. Run `kubectl get storageclass` and `kubectl describe storageclass`
2. Note the provisioner, reclaim policy, and volume binding mode
```sh
azureuser@Tws-lab:~$ kubectl describe storageclass
Name:            standard
IsDefaultClass:  Yes
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"},"name":"standard"},"provisioner":"rancher.io/local-path","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}
,storageclass.kubernetes.io/is-default-class=true
Provisioner:           rancher.io/local-path
Parameters:            <none>
AllowVolumeExpansion:  <unset>
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     WaitForFirstConsumer
Events:                <none>
```
3. With dynamic provisioning, developers only create PVCs — the StorageClass handles PV creation automatically

**Verify:** What is the default StorageClass in your cluster?
```sh
azureuser@Tws-lab:~$ kubectl get storageclass
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  3d
```
**Note:**
static provisioning means an admin creates the PV beforehand; dynamic provisioning means a StorageClass and provisioner create storage in response to the PVC.
- ReclaimPolicy: \
Delete = clean up storage \
Retain = preserve storage/data

---

### Task 6: Dynamic Provisioning
1. Write a PVC manifest that includes `storageClassName: standard` (or your cluster's default)
```sh
zureuser@Tws-lab:~$ kubectl get pvc
NAME          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-vol       Bound     pv-vol   1Gi        RWO            manual         <unset>                 38m
pvc-vol-dyn   Pending                                      standard       <unset>                 11s
azureuser@Tws-lab:~$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-vol   1Gi        RWO            Retain           Bound    default/pvc-vol   manual         <unset>                          47m
```
2. Apply it — a PV should appear automatically in `kubectl get pv`
3. Use this PVC in a Pod, write data, verify it works

```sh
azureuser@Tws-lab:~$ kubectl apply -f redis-pod.yaml 
pod/busybox created
azureuser@Tws-lab:~$ kubectl get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
pvc-vol       Bound    pv-vol                                     1Gi        RWO            manual         <unset>                 41m
pvc-vol-dyn   Bound    pvc-f0ccc677-6764-4235-90b0-05dc73ac6a83   500Mi      RWO            standard       <unset>                 3m26s
azureuser@Tws-lab:~$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                 STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-vol                                     1Gi        RWO            Retain           Bound    default/pvc-vol       manual         <unset>                          50m
pvc-f0ccc677-6764-4235-90b0-05dc73ac6a83   500Mi      RWO            Delete           Bound    default/pvc-vol-dyn   standard       <unset>                          11s
```

**Verify:** How many PVs exist now? Which was manual, which was dynamic? - 2

---

### Task 7: Clean Up
1. Delete all pods first
2. Delete PVCs — check `kubectl get pv` to see what happened -> PV got delete automatically
```sh
azureuser@Tws-lab:~$ kubectl delete pvc pvc-vol-dyn
persistentvolumeclaim "pvc-vol-dyn" deleted from default namespace
azureuser@Tws-lab:~$ kubectl get pv
NAME     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM             STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
pv-vol   1Gi        RWO            Retain           Bound    default/pvc-vol   manual         <unset>                          55m
```
3. The dynamic PV is gone (Delete reclaim policy). The manual PV shows `Released` (Retain policy).
4. Delete the remaining PV manually

**Verify:** Which PV was auto-deleted and which was retained? Why? -> Due to retain policy, dynamically created PV was deleted and manually created one was retained 