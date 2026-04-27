#!/bin/bash

# Configuration
CLUSTER_NAME="cloudkart-eks-cluster"
REGION="eu-west-1"

echo "Starting EKS Cleanup..."

# 1. Update kubeconfig
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# 2. Delete all LoadBalancer services (this prevents VPC deletion from hanging)
echo "Deleting all LoadBalancer services..."
kubectl get svc --all-namespaces -o json | jq -r '.items[] | select(.spec.type=="LoadBalancer") | .metadata.name + " -n " + .metadata.namespace' | xargs -L1 kubectl delete svc 2>/dev/null

# 3. Delete Nginx Ingress if exists
echo "Deleting ingress-nginx..."
helm uninstall nginx-ingress -n ingress-nginx 2>/dev/null

# 4. Terraform Destroy
echo "Running Terraform Destroy..."
cd terraform
terraform destroy -auto-approve
