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

### 2. Configure GitHub Repository Credentials (Secure)

**⚠️ IMPORTANT: Never store credentials in plain text in Git!**

Choose one of these secure methods:

#### Option A: Sealed Secrets (Recommended for GitOps)
```bash
# Install Sealed Secrets if not already installed
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Use the secure deployment script
./deploy-secure.sh
```

#### Option B: External Secrets Operator (Production)
```bash
# Install External Secrets Operator
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/charts/external-secrets/templates/crds.yaml

# Use the secure deployment script
./deploy-secure.sh
```

#### Option C: Environment Variables (Development Only)
```bash
# Set environment variables
export GITHUB_USERNAME=your-username
export GITHUB_TOKEN=your-personal-access-token

# Use the secure deployment script
./deploy-secure.sh
```

### 3. Deploy the Python App

The secure deployment script will automatically deploy the python-app application.

## Security Features

### 🔐 Credential Management
- **Sealed Secrets**: Encrypts secrets before storing in Git
- **External Secrets**: Integrates with external secret stores (Vault, AWS Secrets Manager, etc.)
- **Environment Variables**: For development environments only
- **No Plain Text**: Credentials are never stored in plain text in Git

### 🛡️ Best Practices
- Credentials are validated before deployment
- Secrets are automatically rotated
- Access is controlled through Kubernetes RBAC
- Audit trails for all secret operations

## Configuration Details

### Repository Credentials
- Configures ArgoCD to access your GitHub repository securely
- Supports multiple authentication methods
- Automatically validates credentials before use

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
   - Ensure credentials are properly stored in your secret management system

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
                              │
                              ▼
                       ┌─────────────────┐
                       │  Secret Store   │
                       │  (Vault/AWS/etc)│
                       └─────────────────┘
```

## Next Steps

1. **Customize Values**: Modify the Helm chart values in your python-app repository
2. **Add More Applications**: Create additional application configurations for other services
3. **Set Up CI/CD**: Integrate with GitHub Actions or other CI/CD tools
4. **Monitoring**: Add Prometheus and Grafana for monitoring
5. **Security**: Implement RBAC and network policies
6. **Secret Rotation**: Set up automatic secret rotation policies

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review ArgoCD documentation: https://argo-cd.readthedocs.io/
3. Check Kubernetes events and logs
4. Review your secret management system configuration
