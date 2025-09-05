#!/bin/bash

# Secure deployment script for ArgoCD ULP
set -e

echo "🔐 Secure Deployment for ArgoCD ULP with Python App..."

# Check if we're in the right directory
if [ ! -f "Chart.yaml" ]; then
    echo "❌ Error: Please run this script from the argocd-ULP directory"
    exit 1
fi

# Function to check if External Secrets Operator is installed
check_external_secrets() {
    if kubectl get crd externalsecrets.external-secrets.io >/dev/null 2>&1; then
        echo "✅ External Secrets Operator detected"
        return 0
    else
        echo "❌ External Secrets Operator not found"
        return 1
    fi
}

# Function to check if Sealed Secrets is installed
check_sealed_secrets() {
    if kubectl get crd sealedsecrets.bitnami.com >/dev/null 2>&1; then
        echo "✅ Sealed Secrets detected"
        return 0
    else
        echo "❌ Sealed Secrets not found"
        return 1
    fi
}

# Function to prompt for credentials securely
get_credentials() {
    echo "🔑 Please provide your GitHub credentials:"
    read -p "GitHub Username: " GITHUB_USERNAME
    read -s -p "GitHub Personal Access Token: " GITHUB_TOKEN
    echo ""
    
    # Validate credentials
    if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
        echo "❌ Error: Username and token cannot be empty"
        exit 1
    fi
    
    # Test GitHub API access
    echo "🔍 Testing GitHub API access..."
    if curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -q "login"; then
        echo "✅ GitHub credentials validated successfully"
    else
        echo "❌ Error: Invalid GitHub credentials"
        exit 1
    fi
}

# Function to deploy with External Secrets
deploy_with_external_secrets() {
    echo "🔐 Deploying with External Secrets Operator..."
    
    # Create the external secret
    kubectl apply -f template/repo-creds-external-secret.yaml
    
    echo "⚠️  Note: You need to configure your external secret store (Vault, AWS Secrets Manager, etc.)"
    echo "   with the following keys:"
    echo "   - github/creds.username: $GITHUB_USERNAME"
    echo "   - github/creds.token: $GITHUB_TOKEN"
    echo "   - github/creds.url: https://github.com/pdaxh/python-app"
}

# Function to deploy with Sealed Secrets
deploy_with_sealed_secrets() {
    echo "🔐 Deploying with Sealed Secrets..."
    
    # Create a temporary secret file
    cat > /tmp/temp-secret.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: temp-secret
  namespace: argocd
type: Opaque
stringData:
  username: $GITHUB_USERNAME
  password: $GITHUB_TOKEN
  url: https://github.com/pdaxh/python-app
EOF
    
    # Seal the secret
    echo "🔒 Sealing the secret..."
    kubeseal --format yaml < /tmp/temp-secret.yaml > template/repo-creds-sealed.yaml
    
    # Clean up temp file
    rm /tmp/temp-secret.yaml
    
    # Apply the sealed secret
    kubectl apply -f template/repo-creds-sealed.yaml
    
    echo "✅ Secret sealed and deployed successfully"
}

# Function to deploy with environment variables
deploy_with_env_vars() {
    echo "🔐 Deploying with environment variables..."
    
    # Export credentials
    export GITHUB_USERNAME
    export GITHUB_TOKEN
    
    # Apply using envsubst
    envsubst < template/repo-creds-env.yaml | kubectl apply -f -
    
    echo "✅ Secret deployed using environment variables"
}

# Main deployment logic
main() {
    # Get credentials securely
    get_credentials
    
    # Check available secret management options
    if check_external_secrets; then
        echo "📋 Available options:"
        echo "1. External Secrets Operator (recommended for production)"
        echo "2. Sealed Secrets"
        echo "3. Environment Variables (development only)"
        
        read -p "Choose option (1-3): " choice
        case $choice in
            1) deploy_with_external_secrets ;;
            2) deploy_with_sealed_secrets ;;
            3) deploy_with_env_vars ;;
            *) echo "❌ Invalid choice"; exit 1 ;;
        esac
    elif check_sealed_secrets; then
        echo "📋 Available options:"
        echo "1. Sealed Secrets"
        echo "2. Environment Variables (development only)"
        
        read -p "Choose option (1-2): " choice
        case $choice in
            1) deploy_with_sealed_secrets ;;
            2) deploy_with_env_vars ;;
            *) echo "❌ Invalid choice"; exit 1 ;;
        esac
    else
        echo "⚠️  No secure secret management detected"
        echo "📋 Available options:"
        echo "1. Install External Secrets Operator"
        echo "2. Install Sealed Secrets"
        echo "3. Use Environment Variables (development only)"
        
        read -p "Choose option (1-3): " choice
        case $choice in
            1) echo "📚 Install External Secrets Operator: kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/charts/external-secrets/templates/crds.yaml" ;;
            2) echo "📚 Install Sealed Secrets: kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml" ;;
            3) deploy_with_env_vars ;;
            *) echo "❌ Invalid choice"; exit 1 ;;
        esac
    fi
    
    # Deploy the python app
    echo "🚀 Deploying Python App..."
    kubectl apply -f template/python-app.yaml
    
    echo "✅ Secure deployment complete!"
    echo ""
    echo "🔒 Your credentials are now stored securely"
    echo "📱 Check the application status: kubectl get application python-app -n argocd"
}

# Run main function
main
