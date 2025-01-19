# Kubernetes Administration

[Kubernetes (k8s)](https://kubernetes.io/docs/concepts/overview/) is a portable, extensible, open source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation.  SAS Viya 4 is built on the open source version of k8s as well as cloud provider versions. Ensure the target environment **kubeconfig** is defined for the `kubectl` command to work.  The target environment kubeconfig provided from the IAC build defines the connection path for `kubectl` to work on your local environment. By default, `kubectl` sources its connection info from `~/kube/config`.

**Table of Contents:**
- [Define KUBECONFIG](#define-kubeconfig)
- [Kubectl Cheatsheet](#kubectl-cheatsheet)
- [Start/Stop AKS Cluster](#startstop-aks-cluster)
- [Start/Stop VMs](#startstop-vms)

## Define KUBECONFIG

Manually assign the current kubeconfig from the command line from adhoc environment administration. **Tip:** drag and drop directories within VSCode to the terminal window pane to copy and paste full paths, or right click and copy path.

```bash
# Provide explicit path to k8s configuration file
export KUBECONFIG={{ABSOLUTE_PATH}}

# OR relative path within current working directory
# Running from the root of the project repo
cd ~/dev/deployments/viya4-iac-azure/{{ENVIRONMENT_NAME}}/
export KUBECONFIG={{ENVIRONMENT_NAME}}-aks-kubeconfig.conf
```

Export kubeconfig from Azure:
```bash
az aks get-credentials --resource-group {{RESOURCE_GROUP_NAME}} --name {{AKS_CLUSTER_NAME}} --file kubeconfig.conf
```

## Kubectl Cheatsheet

List all pods across all namespaces:

```bash
kubectl get pod -A
```

Check if pods are running normal:

```bash
kubectl get pod -n <namespace>
```

Check a specific pod and get logging information:

```bash
kubectl describe -n namespace <name of pod>
```

Get All Pod Metrics Across all Namespaces:

```bash
kubectl get PodMetrics --all-namespaces
```

Get public IP address for the Ingress Controller:

```bash
kubectl get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[*].ip}'
```

Get events:

```bash
kubectl -n logging get events
```

Expand into feeding into a grep command to find interesting things:

```bash
kubectl -n logging get events | grep -i warning
```

## Start/Stop AKS Cluster

Use the following command to **stop** the AKS cluster.

```bash
az aks stop --name {{AKS_CLUSTER_NAME}} --resource-group {{RESOURCE_GROUP_NAME}}
```

Use the following command to **start** the AKS cluster.

```bash
az aks start --name {{AKS_CLUSTER_NAME}} --resource-group {{RESOURCE_GROUP_NAME}}
```

## Start/Stop VMs

Use the following commands to stop all virtual machines within a given resource group.

```bash
# Stop all VMs
az vm stop --ids $(az vm list -g {{RESOURCE_GROUP_NAME}} --query "[].id" -o tsv)

# Deallocate VMs to ensure Azure releases unnecessary assets (will get reassigned when restarted)
az vm deallocate --ids $(az vm list -g {{RESOURCE_GROUP_NAME}} --query "[].id" -o tsv)
```

Use the following commands to start all virtual machines within a given resource group.

```bash
# Start all VMs
az vm start --ids $(az vm list -g {{RESOURCE_GROUP_NAME}} --query "[].id" -o tsv)
```
