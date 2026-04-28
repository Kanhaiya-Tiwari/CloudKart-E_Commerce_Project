#!/bin/bash

# ============================================================
# CLOUDKART EKS TERRAFORM DEPLOYMENT GUIDE
# ============================================================
# This guide shows how to deploy the entire CloudKart infrastructure
# on AWS EKS using Terraform in a single unified directory.

set -e

echo "🚀 CloudKart EKS Terraform Deployment"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ============================================================
# PRE-DEPLOYMENT CHECKS
# ============================================================
echo -e "${BLUE}[1/7] Checking prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}✗ AWS CLI not found. Install it first.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}✗ Terraform not found. Install it first.${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl not found. Install it first.${NC}"
    exit 1
fi

if ! command -v helm &> /dev/null; then
    echo -e "${RED}✗ Helm not found. Install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}✗ AWS credentials not configured. Run 'aws configure'.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites met${NC}"
echo ""

# ============================================================
# TERRAFORM INITIALIZATION
# ============================================================
echo -e "${BLUE}[2/7] Initializing Terraform...${NC}"

cd terraform

terraform init

echo -e "${GREEN}✓ Terraform initialized${NC}"
echo ""

# ============================================================
# TERRAFORM VALIDATION
# ============================================================
echo -e "${BLUE}[3/7] Validating Terraform configuration...${NC}"

terraform validate

echo -e "${GREEN}✓ Terraform configuration is valid${NC}"
echo ""

# ============================================================
# TERRAFORM PLAN
# ============================================================
echo -e "${BLUE}[4/7] Creating Terraform plan...${NC}"

terraform plan -out=tfplan

echo -e "${GREEN}✓ Terraform plan created${NC}"
echo ""

# ============================================================
# TERRAFORM APPLY
# ============================================================
echo -e "${BLUE}[5/7] Applying Terraform configuration...${NC}"
echo ""
echo "⚠️  This will create AWS resources (EKS cluster, EC2, VPC, etc.)"
echo "   Estimated cost: ~$500-1000/month depending on usage"
echo ""
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

# Set GitHub token if not already set
if [ -z "$TF_VAR_github_token" ]; then
    echo ""
    echo "Please provide your GitHub Personal Access Token"
    read -sp "GitHub Token: " TF_VAR_github_token
    export TF_VAR_github_token
    echo ""
fi

terraform apply tfplan

echo -e "${GREEN}✓ Terraform apply completed${NC}"
echo ""

# ============================================================
# KUBECONFIG SETUP
# ============================================================
echo -e "${BLUE}[6/7] Setting up kubeconfig...${NC}"

aws eks update-kubeconfig --region eu-west-1 --name cloudkart-eks-cluster

echo -e "${GREEN}✓ kubeconfig updated${NC}"
echo ""

# ============================================================
# VERIFICATION
# ============================================================
echo -e "${BLUE}[7/7] Verifying cluster...${NC}"

echo ""
echo "Waiting for cluster nodes to be ready..."
kubectl wait --for=condition=Ready node --all --timeout=300s || true

echo ""
echo "Checking Helm deployments..."
helm list -a --all-namespaces

echo ""
echo "Checking namespaces..."
kubectl get namespaces

echo ""
echo -e "${GREEN}✓ Deployment completed!${NC}"
echo ""

# ============================================================
# NEXT STEPS
# ============================================================
echo ""
echo "🎉 Deployment Summary"
echo "====================="
echo ""
echo "Infrastructure created in AWS region: eu-west-1"
echo ""
echo "📍 Important URLs & Commands:"
echo ""
echo "1️⃣  Get cluster info:"
echo "    kubectl cluster-info"
echo ""
echo "2️⃣  ArgoCD Admin Password:"
echo "    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode"
echo ""
echo "3️⃣  Access ArgoCD UI:"
echo "    kubectl port-forward svc/argocd-server -n argocd 8443:443"
echo "    Then visit: https://localhost:8443"
echo ""
echo "4️⃣  CloudKart Deployment Status:"
echo "    kubectl get deployments -n cloudkart"
echo ""
echo "5️⃣  View Ingress URL:"
echo "    kubectl get ingress -n cloudkart"
echo ""
echo "6️⃣  Jenkins Server:"
terraform output jenkins_url
echo ""
echo "7️⃣  Terraform Outputs:"
terraform output
echo ""
echo "====================="
echo "✓ All done! Your CloudKart infrastructure is ready."
echo ""

cd ..
