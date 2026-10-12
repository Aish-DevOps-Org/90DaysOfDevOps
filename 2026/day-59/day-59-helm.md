# Day 59 – Helm — Kubernetes Package Manager

### Task 1: Install Helm
1. Install Helm (brew, curl script, or chocolatey depending on your OS)
2. Verify with `helm version` and `helm env`

Three core concepts:
- **Chart** — a package of Kubernetes manifest templates
- **Release** — a specific installation of a chart in your cluster
- **Repository** — a collection of charts (like a package repo)

**Verify:** What version of Helm is installed?
```sh
azureuser@Tws-lab:~$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4
azureuser@Tws-lab:~$ chmod 700 get_helm.sh
azureuser@Tws-lab:~$ ./get_helm.sh
Downloading https://get.helm.sh/helm-v4.3.0-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm
azureuser@Tws-lab:~$ helm version
version.BuildInfo{Version:"v4.3.0", GitCommit:"bec5b06ed841fe5269972d864d5177944fd5970f", GitTreeState:"clean", GoVersion:"go1.27.1", KubeClientVersion:"v1.37"}
```

---

### Task 2: Add a Repository and Search
1. Add the Bitnami repository: `helm repo add bitnami https://charts.bitnami.com/bitnami`
2. Update: `helm repo update`
3. Search: `helm search repo nginx` and `helm search repo bitnami`

**Verify:** How many charts does Bitnami have? -> 144

---

### Task 3: Install a Chart
1. Deploy nginx: `helm install my-nginx bitnami/nginx`
2. Check what was created: `kubectl get all`
```sh
azureuser@Tws-lab:~$ kubectl get all
NAME                            READY   STATUS    RESTARTS   AGE
pod/my-nginx-5ff6687869-p8m6w   1/1     Running   0          2m35s

NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
service/my-nginx     LoadBalancer   10.96.224.55   <pending>     80:32757/TCP,443:31797/TCP   2m35s

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/my-nginx   1/1     1            1           2m35s

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/my-nginx-5ff6687869   1         1         1       2m35s
```

3. Inspect the release: `helm list`, `helm status my-nginx`, `helm get manifest my-nginx`
```sh
azureuser@Tws-lab:~$ helm list
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
my-nginx        default         1               2026-10-11 14:41:06.375354402 +0000 UTC deployed        nginx-25.2.1    1.31.6
azureuser@Tws-lab:~$ helm status my-nginx
NAME: my-nginx
LAST DEPLOYED: Sun Oct 11 14:41:06 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
RESOURCES:
==> v1/Secret
NAME           TYPE                DATA   AGE
my-nginx-tls   kubernetes.io/tls   3      3m35s

==> v1/Service
NAME       TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
my-nginx   LoadBalancer   10.96.224.55   <pending>     80:32757/TCP,443:31797/TCP   3m35s

==> v1/Deployment
NAME       READY   UP-TO-DATE   AVAILABLE   AGE
my-nginx   1/1     1            1           3m35s

==> v1/Pod(related)
NAME                        READY   STATUS    RESTARTS   AGE
my-nginx-5ff6687869-p8m6w   1/1     Running   0          3m35s

==> v1/NetworkPolicy
NAME       POD-SELECTOR                                                       AGE
my-nginx   app.kubernetes.io/instance=my-nginx,app.kubernetes.io/name=nginx   3m35s

==> v1/PodDisruptionBudget
NAME       MIN AVAILABLE   MAX UNAVAILABLE   ALLOWED DISRUPTIONS   AGE
my-nginx   N/A             1                 1                     3m35s

==> v1/ServiceAccount
NAME       AGE
my-nginx   3m35s


TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 25.2.1
APP VERSION: 1.31.6

```
One command replaced writing a Deployment, Service, and ConfigMap by hand.

**Verify:** How many Pods are running? What Service type was created? -> 1 pod. LoadBalancer svc

---

### Task 4: Customize with Values
1. View defaults: `helm show values bitnami/nginx`
2. Install a custom release with `--set replicaCount=3 --set service.type=NodePort`
```sh
azureuser@Tws-lab:~$ helm install my-nginx bitnami/nginx --set replicaCount=3 --set service.type=NodePort
NAME: my-nginx
LAST DEPLOYED: Mon Oct 12 15:59:25 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 25.2.1
APP VERSION: 1.31.6

azureuser@Tws-lab:~$ kubectl get all -o wide
NAME                            READY   STATUS    RESTARTS   AGE   IP           NODE                           NOMINATED NODE   READINESS GATES
pod/my-nginx-5ff6687869-5rj76   1/1     Running   0          59s   10.244.0.9   devops-cluster-control-plane   <none>           <none>
pod/my-nginx-5ff6687869-6ppf8   1/1     Running   0          59s   10.244.0.7   devops-cluster-control-plane   <none>           <none>
pod/my-nginx-5ff6687869-6zf2g   1/1     Running   0          59s   10.244.0.8   devops-cluster-control-plane   <none>           <none>

NAME                 TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE     SELECTOR
service/my-nginx     NodePort    10.96.252.75   <none>        80:32347/TCP,443:30618/TCP   59s     app.kubernetes.io/instance=my-nginx,app.kubernetes.io/name=nginx

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                                      SELECTOR
deployment.apps/my-nginx   3/3     3            3           59s   nginx        registry-1.docker.io/bitnami/nginx:latest   app.kubernetes.io/instance=my-nginx,app.kubernetes.io/name=nginx

NAME                                  DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                                      SELECTOR
replicaset.apps/my-nginx-5ff6687869   3         3         3       59s   nginx        registry-1.docker.io/bitnami/nginx:latest   app.kubernetes.io/instance=my-nginx,app.kubernetes.io/name=nginx,pod-template-hash=5ff6687869
```
3. Create a `custom-values.yaml` file with replicaCount, service type, and resource limits

4. Install another release using `-f custom-values.yaml`
```sh
azureuser@Tws-lab:~$ helm install custom-nginx bitnami/nginx -f custom-values.yaml
NAME: custom-nginx
LAST DEPLOYED: Mon Oct 12 16:04:56 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 25.2.1
APP VERSION: 1.31.6

NAME                               READY   STATUS    RESTARTS   AGE    IP            NODE                           NOMINATED NODE   READINESS GATES
pod/custom-nginx-6d6d5988b-rp86j   1/1     Running   0          32s    10.244.0.13   devops-cluster-control-plane   <none>           <none>
pod/custom-nginx-6d6d5988b-tnbf2   1/1     Running   0          32s    10.244.0.12   devops-cluster-control-plane   <none>           <none>

NAME                   TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE     SELECTOR
service/custom-nginx   ClusterIP   10.96.82.8     <none>        80/TCP,443/TCP               32s     app.kubernetes.io/instance=custom-nginx,app.kubernetes.io/name=nginx

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS   IMAGES                                      SELECTOR
deployment.apps/custom-nginx   2/2     2            2           32s    nginx        registry-1.docker.io/bitnami/nginx:latest   app.kubernetes.io/instance=custom-nginx,app.kubernetes.io/name=nginx

NAME                                     DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES                                      SELECTOR
replicaset.apps/custom-nginx-6d6d5988b   2         2         2       32s    nginx        registry-1.docker.io/bitnami/nginx:latest   app.kubernetes.io/instance=custom-nginx,app.kubernetes.io/name=nginx,pod-template-hash=6d6d5988b
```
5. Check overrides: `helm get values <release-name>`
```sh
azureuser@Tws-lab:~$ helm get values my-nginx
USER-SUPPLIED VALUES:
replicaCount: 3
service:
  type: NodePort
azureuser@Tws-lab:~$ helm get values custom-nginx
USER-SUPPLIED VALUES:
replicaCount: 2
resource:
  requests:
    cpu: 250m
    memory: 251Mi
service:
  port: 8080
  type: ClusterIP
```
**Verify:** Does the values file release have the correct replicas and service type? - Yes

---

### Task 5: Upgrade and Rollback
1. Upgrade: `helm upgrade my-nginx bitnami/nginx --set replicaCount=5`
```sh
azureuser@Tws-lab:~$ helm get values my-nginx
USER-SUPPLIED VALUES:
replicaCount: 5
```
2. Check history: `helm history my-nginx`
```sh
azureuser@Tws-lab:~$ helm history my-nginx
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Oct 12 15:59:25 2026        superseded      nginx-25.2.1    1.31.6          Install complete
2               Mon Oct 12 16:07:52 2026        deployed        nginx-25.2.1    1.31.6          Upgrade complete
```
3. Rollback: `helm rollback my-nginx 1`
4. Check history again — rollback creates a new revision (3), not overwriting revision 2
```sh
azureuser@Tws-lab:~$ helm history my-nginx
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Oct 12 15:59:25 2026        superseded      nginx-25.2.1    1.31.6          Install complete
2               Mon Oct 12 16:07:52 2026        superseded      nginx-25.2.1    1.31.6          Upgrade complete
3               Mon Oct 12 16:08:44 2026        deployed        nginx-25.2.1    1.31.6          Rollback to 1

azureuser@Tws-lab:~$ helm get values my-nginx
USER-SUPPLIED VALUES:
replicaCount: 3
service:
  type: NodePort
```
Same concept as Deployment rollouts from Day 52, but at the full stack level.

**Verify:** How many revisions after the rollback? - 3

---

### Task 6: Create Your Own Chart
1. Scaffold: `helm create my-app`
```sh
flask-app/
├── Chart.yaml
├── charts
├── templates
│   ├── NOTES.txt
│   ├── _helpers.tpl
│   ├── deployment.yaml
│   ├── hpa.yaml
│   ├── httproute.yaml
│   ├── ingress.yaml
│   ├── service.yaml
│   ├── serviceaccount.yaml
│   └── tests
│       └── test-connection.yaml
└── values.yaml

4 directories, 11 files
```
2. Explore the directory: `Chart.yaml`, `values.yaml`, `templates/deployment.yaml`
3. Look at the Go template syntax in templates: `{{ .Values.replicaCount }}`, `{{ .Chart.Name }}`
4. Edit `values.yaml` — set replicaCount to 3 and image to nginx:1.25
5. Validate: `helm lint my-app`
```sh
azureuser@Tws-lab:~$ helm lint flask-app
==> Linting flask-app
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed    
```
6. Preview: `helm template my-release ./my-app`
```sh
azureuser@Tws-lab:~$ helm template my-release ./flask-app/
---
# Source: flask-app/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-release-flask-app
  labels:
    helm.sh/chart: flask-app-0.1.0
    app.kubernetes.io/name: flask-app
    app.kubernetes.io/instance: my-release
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
automountServiceAccountToken: true

---
# Source: flask-app/templates/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-release-flask-app
  labels:
    helm.sh/chart: flask-app-0.1.0
    app.kubernetes.io/name: flask-app
    app.kubernetes.io/instance: my-release
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: flask-app
    app.kubernetes.io/instance: my-release

---
# Source: flask-app/templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-release-flask-app
  labels:
    helm.sh/chart: flask-app-0.1.0
    app.kubernetes.io/name: flask-app
    app.kubernetes.io/instance: my-release
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: flask-app
      app.kubernetes.io/instance: my-release
  template:
    metadata:
      labels:
        helm.sh/chart: flask-app-0.1.0
        app.kubernetes.io/name: flask-app
        app.kubernetes.io/instance: my-release
        app.kubernetes.io/version: "1.16.0"
        app.kubernetes.io/managed-by: Helm
    spec:
      serviceAccountName: my-release-flask-app
      containers:
        - name: flask-app
          image: "nginx:1.25"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
---
# Source: flask-app/templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "my-release-flask-app-test-connection"
  labels:
    helm.sh/chart: flask-app-0.1.0
    app.kubernetes.io/name: flask-app
    app.kubernetes.io/instance: my-release
    app.kubernetes.io/version: "1.16.0"
    app.kubernetes.io/managed-by: Helm
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['my-release-flask-app:80']
  restartPolicy: Never
```
7. Install: `helm install my-release ./my-app`
```sh
NAME: my-release
LAST DEPLOYED: Mon Oct 12 16:35:08 2026
NAMESPACE: default
STATUS: deployed
REVISION: 1
DESCRIPTION: Install complete
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=flask-app,app.kubernetes.io/instance=my-release" -o jsonpath="{.items[0].metadata.name}")
  export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT
```
8. Upgrade: `helm upgrade my-release ./my-app --set replicaCount=5`
```sh
azureuser@Tws-lab:~$ helm get values my-release
USER-SUPPLIED VALUES:
replicaCount: 5
azureuser@Tws-lab:~$ helm history my-release
REVISION        UPDATED                         STATUS          CHART           APP VERSION     DESCRIPTION
1               Mon Oct 12 16:43:55 2026        superseded      flask-app-0.1.0 1.16.0          Install complete
2               Mon Oct 12 16:45:00 2026        deployed        flask-app-0.1.0 1.16.0          Upgrade complete
```
**Verify:** After installing, 3 replicas? After upgrading, 5? -> yes

---

### Task 7: Clean Up
1. Uninstall all releases: `helm uninstall <name>` for each
2. Remove chart directory and values file
3. Use `--keep-history` if you want to retain release history for auditing

**Verify:** Does `helm list` show zero releases?

## Hints
- `helm show values <chart>` — see what you can customize
- `--set key=value` for single overrides, `-f values.yaml` for files
- Nested values use dots: `--set service.type=NodePort`
- `helm get values <release>` shows overrides, `--all` for everything
- `helm template` renders without installing — great for debugging
- `helm lint` validates chart structure before installing
- Templates: `{{ .Values.key }}`, `{{ .Chart.Name }}`, `{{ .Release.Name }}`