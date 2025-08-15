# Backstage ULP - GitOps Setup

This repository contains the ArgoCD application definitions for deploying Backstage ULP using GitOps principles.

## Architecture

- **Backstage-ULP**: Contains the Backstage application code and Kubernetes manifests
- **argocd-ULP**: Contains ArgoCD application definitions for GitOps deployment

## GitOps Workflow

1. **Development**: Make changes to Backstage application in `Backstage-ULP` repository
2. **Commit & Push**: Changes are committed and pushed to the main branch
3. **ArgoCD Sync**: ArgoCD automatically detects changes and syncs the application
4. **Deployment**: Kubernetes resources are updated according to the new manifests

## Prerequisites

- ArgoCD running in your cluster
- Access to the `Backstage-ULP` repository
- Proper RBAC permissions for ArgoCD

## Deployment

1. Update the `repoURL` in `backstage-app.yaml` to point to your actual repository
2. Apply the ArgoCD application:
   ```bash
   kubectl apply -f backstage-app.yaml -n argocd
   ```

## Monitoring

- Check application status in ArgoCD UI
- Monitor Backstage pods in the `backstage` namespace
- Review sync history and logs in ArgoCD

## Benefits of This Setup

- **GitOps**: All deployments are version controlled and auditable
- **Automation**: Automatic sync when changes are pushed
- **Consistency**: Same deployment pattern across all applications
- **Rollback**: Easy rollback to previous versions via Git
- **Collaboration**: Team can review deployment changes via PRs
