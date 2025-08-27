#!/bin/bash

# Deploy ArgoCD ULP with Python App
set -e

echo "🚀 Deploying ArgoCD ULP with Python App..."

# Check if we're in the right directory
if [ ! -f "Chart.yaml" ]; then
    echo "❌ Error: Please run this script from the argocd-ULP directory"
    exit 1
fi

# Deploy ArgoCD
echo "📦 Deploying ArgoCD..."
helm upgrade --install argocd-ulp . \
    --namespace argocd \
    --create-namespace \
    --wait

# Wait for ArgoCD to be ready
echo "⏳ Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-ulp-argo-cd-server -n argocd

# Get ArgoCD admin password
echo "🔑 ArgoCD admin password:"
kubectl -n argocd get secret argocd-ulp-argo-cd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

# Get ArgoCD server URL
echo "🌐 ArgoCD server URL:"
kubectl get svc argocd-ulp-argo-cd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
echo ":80"

echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Update the repo-creds-https.yaml with your GitHub credentials"
echo "2. Apply the repository credentials: kubectl apply -f template/repo-creds-https.yaml"
echo "3. Apply the python-app application: kubectl apply -f template/python-app.yaml"
echo "4. Access ArgoCD UI and verify the application is syncing"
