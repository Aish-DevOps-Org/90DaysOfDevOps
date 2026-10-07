# Day 54 – Kubernetes ConfigMaps and Secrets

## Challenge Tasks

### Task 1: Create a ConfigMap from Literals
1. Use `kubectl create configmap` with `--from-literal` to create a ConfigMap called `app-config` with keys `APP_ENV=production`, `APP_DEBUG=false`, and `APP_PORT=8080`
2. Inspect it with `kubectl describe configmap app-config` and `kubectl get configmap app-config -o yaml`
3. Notice the data is stored as plain text — no encoding, no encryption

**Verify:** Can you see all three key-value pairs?

```bash
azureuser@Tws-lab:~$ kubectl create configmap app-config --from-literal=APP_ENV=production --from-literal=APP_DEBUG=false --from-literal=APP_PORT=8080
configmap/app-config created

azureuser@Tws-lab:~$ kubectl describe configmap app-config
Name:         app-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
APP_DEBUG:
----
false

APP_ENV:
----
production

APP_PORT:
----
8080

BinaryData
====

Events:  <none>

azureuser@Tws-lab:~$ kubectl get configmap app-config -o yaml
apiVersion: v1
data:
  APP_DEBUG: "false"
  APP_ENV: production
  APP_PORT: "8080"
kind: ConfigMap
metadata:
  creationTimestamp: "2026-10-07T15:25:15Z"
  name: app-config
  namespace: default
  resourceVersion: "68382"
  uid: 26b8619a-d82e-48d7-900e-cffe844cb5da
```

---

### Task 2: Create a ConfigMap from a File
1. Write a custom Nginx config file that adds a `/health` endpoint returning "healthy"
```
server {
    listen 80;
    server_name localhost;

    location /health {
        default_type text/plain;
        return 200 "healthy";
    }

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
```
2. Create a ConfigMap from this file using `kubectl create configmap nginx-config --from-file=default.conf=<your-file>`
3. The key name (`default.conf`) becomes the filename when mounted into a Pod

**Verify:** Does `kubectl get configmap nginx-config -o yaml` show the file contents?

```bash
azureuser@Tws-lab:~$ kubectl create configmap nginx-config --from-file=default.conf=health.conf
configmap/nginx-config created
azureuser@Tws-lab:~$ kubectl get configmap nginx-config -o yaml

apiVersion: v1
data:
  default.conf: "server {\n    listen 80;\n    server_name _;\n\n    # Health check
    endpoint\n    location /health {\n        default_type text/plain;\n        return
    200 \"healthy\";\n    }\n\n    # Optional default location\n    location / {\n\troot
    /usr/share/nginx/html;\n\tindex index.html;\n\t}\n}\n"
kind: ConfigMap
metadata:
  creationTimestamp: "2026-10-07T15:38:50Z"
  name: nginx-config
  namespace: default
  resourceVersion: "69522"
  uid: 5801defc-54eb-4060-9e79-6662ea47b7ae


azureuser@Tws-lab:~$ kubectl describe configmap nginx-config
Name:         nginx-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
default.conf:
----
server {
    listen 80;
    server_name _;

    # Health check endpoint
    location /health {
        default_type text/plain;
        return 200 "healthy";
    }

    # Optional default location
    location / {
  root /usr/share/nginx/html;
  index index.html;
  }
}



BinaryData
====

Events:  <none>
```

---

### Task 3: Use ConfigMaps in a Pod
1. Write a Pod manifest that uses `envFrom` with `configMapRef` to inject all keys from `app-config` as environment variables. Use a busybox container that prints the values.
```bash
apiVersion: v1
kind: Pod
metadata:
  name: busybox
spec:
  containers:
  - name: app
    image: busybox:latest
    command: ["/bin/sh", "-c", "printenv"]
    envFrom:
      - configMapRef:
          name: app-config
```
```bash
azureuser@Tws-lab:~$ kubectl logs busybox
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
APP_DEBUG=false
HOSTNAME=busybox
SHLVL=1
HOME=/root
APP_PORT=8080
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
APP_ENV=production
KUBERNETES_SERVICE_HOST=10.96.0.1
PWD=/
```
2. Write a second Pod manifest that mounts `nginx-config` as a volume at `/etc/nginx/conf.d`. Use the nginx image.

```bash
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
      volumeMounts:
        - name: config
          mountPath: "/etc/nginx/conf.d"
          readOnly: true
  volumes:
    - name: config
      configMap:
        name: nginx-config
```

3. Test that the mounted config works: `kubectl exec <pod> -- curl -s http://localhost/health`

Use environment variables for simple key-value settings. Use volume mounts for full config files.

**Verify:** Does the `/health` endpoint respond?

```bash
azureuser@Tws-lab:~$ kubectl get pods -o wide
NAME      READY   STATUS    RESTARTS      AGE    IP            NODE                           NOMINATED NODE   READINESS GATES
busybox   1/1     Running   5 (83s ago)   3m5s   10.244.0.19   devops-cluster-control-plane   <none>           <none>
nginx     1/1     Running   0             2m7s   10.244.0.20   devops-cluster-control-plane   <none>           <none>

azureuser@Tws-lab:~$ kubectl exec nginx -- curl -s http://localhost/health
healthy

azureuser@Tws-lab:~$ kubectl exec nginx -- curl -s http://localhost
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
```

---

### Task 4: Create a Secret
1. Use `kubectl create secret generic db-credentials` with `--from-literal` to store `DB_USER=admin` and `DB_PASSWORD=s3cureP@ssw0rd`
2. Inspect with `kubectl get secret db-credentials -o yaml` — the values are base64-encoded
3. Decode a value: `echo '<base64-value>' | base64 --decode`

**base64 is encoding, not encryption.** Anyone with cluster access can decode Secrets. The real advantages are RBAC separation, tmpfs storage on nodes, and optional encryption at rest.

**Verify:** Can you decode the password back to plaintext?
```bash
azureuser@Tws-lab:~$ kubectl create secret generic db-credentials --from-literal=DB_USER=admin --from-literal=DB_PASSWORD=s3cureP@ssw0rd
secret/db-credentials created

azureuser@Tws-lab:~$ kubectl get secret db-credentials -o yaml
apiVersion: v1
data:
  DB_PASSWORD: czNjdXJlUEBzc3cwcmQ=
  DB_USER: YWRtaW4=
kind: Secret
metadata:
  creationTimestamp: "2026-10-07T16:08:19Z"
  name: db-credentials
  namespace: default
  resourceVersion: "72064"
  uid: f629b168-50ae-41a6-bad2-bd475dfdbf31
type: Opaque

azureuser@Tws-lab:~$ echo 'czNjdXJlUEBzc3cwcmQ=' | base64 --decode
s3cureP@ssw0rd

azureuser@Tws-lab:~$ echo 'YWRtaW4=' | base64 --decode
admin
```

---

### Task 5: Use Secrets in a Pod
1. Write a Pod manifest that injects `DB_USER` as an environment variable using `secretKeyRef`
2. In the same Pod, mount the entire `db-credentials` Secret as a volume at `/etc/db-credentials` with `readOnly: true`
```bash
apiVersion: v1
kind: Pod
metadata: 
  name: sql
spec:
  containers:
    - name: sql
      image: mysql:latest
      ports:
        -  containerPort: 1433
      env:
        - name: MYSQL_USERNAME
          valueFrom:
            secretKeyRef: 
              name: db-credentials 
              key: DB_USER
      volumeMounts:
      - name: db-cred
        mountPath: "/etc/db-credentials"
        readOnly: true 
  volumes:
  - name: db-cred
    secret:
      secretName: db-credentials
```
3. Verify: each Secret key becomes a file, and the content is the decoded plaintext value

**Verify:** Are the mounted file values plaintext or base64?
```sh
azureuser@Tws-lab:~$ kubectl apply -f sql-pod.yaml 
pod/sql created
azureuser@Tws-lab:~$ kubectl exec sql -- ls /etc/db-credentials
DB_PASSWORD
DB_USER

azureuser@Tws-lab:~$ kubectl exec sql -- printenv
MYSQL_USERNAME=admin
```

---

### Task 6: Update a ConfigMap and Observe Propagation
1. Create a ConfigMap `live-config` with a key `message=hello`
```bash
azureuser@Tws-lab:~$ kubectl create configmap live-config --from-literal=message=hello
configmap/live-config created
azureuser@Tws-lab:~$ kubectl describe configmap live-config
Name:         live-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
message:
----
hello
```

2. Write a Pod that mounts this ConfigMap as a volume and reads the file in a loop every 5 seconds
```bash
apiVersion: v1
kind: Pod
metadata:
  name: live-pod
spec:
  containers:
    - name: busybox
      image: busybox:latest
      command:
        - /bin/sh
        - -c
        - |
          while true; do
            echo "$(date): $(cat /etc/vol/message)"
            sleep 5
          done
      volumeMounts:
      - name: vol
        mountPath: "/etc/vol"
        readOnly: false
  volumes:
  - name: vol
    configMap:
      name: live-config

azureuser@Tws-lab:~$ kubectl logs live-pod
Wed Oct  7 17:07:00 UTC 2026: hello
Wed Oct  7 17:07:05 UTC 2026: hello
Wed Oct  7 17:07:10 UTC 2026: hello
Wed Oct  7 17:07:15 UTC 2026: hello
Wed Oct  7 17:07:20 UTC 2026: hello
```
3. Update the ConfigMap: `kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'`
4. Wait 30-60 seconds — the volume-mounted value updates automatically
5. Environment variables from earlier tasks do NOT update — they are set at pod startup only

**Verify:** Did the volume-mounted value change without a pod restart? -> yes

```bash
azureuser@Tws-lab:~$ kubectl describe configmap live-config
Name:         live-config
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
message:
----
world


BinaryData
====

Events:  <none>
azureuser@Tws-lab:~$ kubectl logs live-pod
Wed Oct  7 17:08:45 UTC 2026: hello
Wed Oct  7 17:08:50 UTC 2026: hello
Wed Oct  7 17:08:55 UTC 2026: hello
Wed Oct  7 17:09:00 UTC 2026: hello
Wed Oct  7 17:09:05 UTC 2026: hello
Wed Oct  7 17:09:10 UTC 2026: hello
Wed Oct  7 17:09:15 UTC 2026: world
Wed Oct  7 17:09:20 UTC 2026: world
```
---

### Task 7: Clean Up
Delete all pods, ConfigMaps, and Secrets you created.