# Argo CD ULP

This repository wraps the [Argo CD Helm chart](https://artifacthub.io/packages/helm/argo/argo-cd) with our own defaults and environment-specific overrides.

---

## 📦 Prerequisites

- A running Kubernetes cluster (v1.24+ recommended).
- `kubectl` installed and configured to point at the cluster.
- `helm` v3.8.0 or later installed.

---

## 🛠️ Prepare Namespace

```bash
kubectl create namespace argocd
```

*(Safe to ignore if it already exists.)*

---

## 📥 Install Dependencies

From the repo root:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm dependency update .
```

---

## 🚀 Install / Upgrade Argo CD

Base installation (shared/default values):

```bash
helm upgrade --install argocd . -n argocd -f values.yaml
```

Development environment (base + dev overrides):

```bash
helm upgrade --install argocd . -n argocd -f values.yaml -f values-dev.yaml
```

Production environment (base + prod overrides):

```bash
helm upgrade --install argocd . -n argocd -f values.yaml -f values-prod.yaml
```

---

## 🔑 Access Argo CD

### Port-forward (if using ClusterIP service):
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Then open: [https://localhost:8080](https://localhost:8080)

### LoadBalancer or Ingress:
- Use the external IP (LoadBalancer) or DNS host (Ingress) defined in your values file.

---

## 👤 Login

Get the initial admin password:
```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

- Username: `admin`  
- Password: (from above command)

---

## 📂 Repo Structure

```
argocd-ULP/
├── Chart.yaml          # Declares dependency on official argo-cd chart
├── values.yaml         # Base configuration
├── values-dev.yaml     # Dev overrides
├── values-prod.yaml    # Prod overrides
├── templates/          # Extra Kubernetes manifests (namespace, projects, repo creds, etc.)
├── charts/             # Auto-populated dependencies
└── README.md           # This file
```

---

## ✅ Next Steps

- Configure Ingress or LoadBalancer for production access.
- Add `AppProject` and `Application` manifests in `templates/` to bootstrap workloads.
- Optionally, let Argo CD manage itself using the “App of Apps” pattern.
