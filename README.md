# ArgoCD ULP with Python App

This repository contains the ArgoCD configuration for deploying and managing the python-app repository.

## Prerequisites

- Kubernetes cluster running
- `kubectl` configured to access your cluster
- `helm` installed
- GitHub personal access token with repo access

## Quick Start

### 1. Deploy ArgoCD

```bash
cd argocd-ULP
./deploy.sh
```

### 2. Configure GitHub Repository Credentials

Edit `template/repo-creds-https.yaml` and replace:
- `<your-github-username>` with your GitHub username
- `<your-github-personal-access-token>` with your GitHub personal access token

Apply the credentials:
```bash
kubectl apply -f template/repo-creds-https.yaml
```

### 3. Deploy the Python App

```bash
kubectl apply -f template/python-app.yaml
```

## Configuration Details

### Repository Credentials (`repo-creds-https.yaml`)
- Configures ArgoCD to access your GitHub repository
- Uses HTTPS authentication with username and personal access token

### Python App Application (`python-app.yaml`)
- Points to your `python-app` repository
- Uses the Helm chart located at `helm/flask-app-chart`
- Automatically syncs and manages the application
- Creates the `python-app` namespace

### Helm Chart Integration
The application is configured to use the Helm chart from your python-app repository:
- **Chart Path**: `helm/flask-app-chart`
- **Release Name**: `python-app`
- **Namespace**: `python-app`
- **Values File**: `values.yaml` (from the chart)

## Accessing ArgoCD

After deployment, you can access the ArgoCD UI:

1. **Get the admin password**:
   ```bash
   kubectl -n argocd get secret argocd-ulp-argo-cd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

2. **Port forward to access the UI**:
   ```bash
   kubectl port-forward svc/argocd-ulp-argo-cd-server -n argocd 8080:80
   ```

3. **Open your browser** and go to `http://localhost:8080`
4. **Login** with username `admin` and the password from step 1

## Application Management

### Manual Sync
If you need to manually sync the application:
```bash
kubectl -n argocd patch application python-app -p '{"spec":{"syncPolicy":{"automated":{"prune":true,"selfHeal":true}}}}'
```

### Check Application Status
```bash
kubectl get application python-app -n argocd
kubectl describe application python-app -n argocd
```

### View Application Resources
```bash
kubectl get all -n python-app
```

## Troubleshooting

### Common Issues

1. **Repository Access Denied**
   - Verify your GitHub personal access token has the correct permissions
   - Check that the repository URL is correct

2. **Application Not Syncing**
   - Check the application status in ArgoCD UI
   - Verify the Helm chart path is correct
   - Check for any validation errors

3. **Resources Not Created**
   - Ensure the namespace exists or `CreateNamespace=true` is set
   - Check if there are any resource quotas or policies blocking creation

### Logs
```bash
# ArgoCD server logs
kubectl logs -n argocd deployment/argocd-ulp-argo-cd-server

# ArgoCD application controller logs
kubectl logs -n argocd deployment/argocd-ulp-argo-cd-application-controller

# Python app logs
kubectl logs -n python-app deployment/python-app
```

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │     ArgoCD      │    │   Kubernetes    │
│  (python-app)   │◄──►│     Server      │◄──►│     Cluster     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Application    │
                       │  Controller     │
                       └─────────────────┘
```

## Next Steps

1. **Customize Values**: Modify the Helm chart values in your python-app repository
2. **Add More Applications**: Create additional application configurations for other services
3. **Set Up CI/CD**: Integrate with GitHub Actions or other CI/CD tools
4. **Monitoring**: Add Prometheus and Grafana for monitoring
5. **Security**: Implement RBAC and network policies

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review ArgoCD documentation: https://argo-cd.readthedocs.io/
3. Check Kubernetes events and logs
