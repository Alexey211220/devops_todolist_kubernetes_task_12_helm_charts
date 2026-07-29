# Preparation

Before validation, deploy all required Kubernetes resources using the `bootstrap.sh` script.

Make the script executable:

```bash
chmod +x bootstrap.sh
```

Run the script from the root directory of the repository:

```bash
./bootstrap.sh
```

# Validation Instructions

## 1. Create the kind cluster

Run from the repository root:

```bash
kind create cluster --name todoapp --config cluster.yml
```

Wait until all nodes are ready:

```bash
kubectl wait --for=condition=Ready nodes --all --timeout=120s
```

## 2. Check node labels and taints

Check labels:

```bash
kubectl get nodes --show-labels
```

Verify that:

- two worker nodes have the label `app=mysql`;
- three worker nodes have the label `app=todoapp`.

Add the required taint to MySQL nodes:

```bash
kubectl taint nodes -l app=mysql app=mysql:NoSchedule
```

Check taints:

```bash
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.spec.taints}{"\n"}{end}'
```

Verify that MySQL nodes have the taint:

```text
app=mysql:NoSchedule
```

## 3. Validate the Helm charts

Validate the parent chart:

```bash
helm lint ./.infrastructure/helm-chart/todoapp
```

Validate the MySQL subchart:

```bash
helm lint ./.infrastructure/helm-chart/todoapp/charts/mysql
```

Render the parent chart together with the MySQL subchart:

```bash
helm template todoapp ./.infrastructure/helm-chart/todoapp
```

Both `helm lint` commands should finish with:

```text
1 chart(s) linted, 0 chart(s) failed
```

## 4. Install the Helm chart

```bash
helm upgrade --install todoapp ./.infrastructure/helm-chart/todoapp
```

Check the installed release:

```bash
helm list -A
```

## 5. Check deployed resources

```bash
kubectl get all,cm,secret,ing -A
```

Check application Pods:

```bash
kubectl get pods -n todoapp -o wide
```

Check MySQL Pods:

```bash
kubectl get pods -n mysql -o wide
```

Verify that:

- todoapp Pods are running;
- MySQL Pods are running;
- MySQL Pods are scheduled on different nodes labeled `app=mysql`;
- todoapp Pods are scheduled on nodes labeled `app=todoapp` whenever possible.

## 6. Validate RBAC

```bash
kubectl auth can-i list secrets   --as=system:serviceaccount:todoapp:todoapp-secrets-reader   -n todoapp
```

Expected result:

```text
yes
```

## 7. Check the application

Start port forwarding:

```bash
kubectl port-forward -n todoapp deployment/todoapp-deployment 8080:8080
```

Open:

```text
http://localhost:8080
```

The command must remain running while the application is being checked.

## 8. Save the deployment output

From the repository root:

```bash
kubectl get all,cm,secret,ing -A > output.log
```
