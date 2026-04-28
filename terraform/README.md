# CloudKart EKS Terraform Infrastructure

Complete Infrastructure-as-Code (IaC) setup for deploying CloudKart on AWS EKS using Terraform.

## 📋 Infrastructure Components

### Core Infrastructure
- **VPC Module**: Custom VPC with public, private, and intra subnets
- **EKS Cluster**: Kubernetes cluster with managed node groups
- **EC2 Instance**: Jenkins CI/CD server for automation
- **Security Groups**: Properly configured network access

### Kubernetes Add-ons (Helm)
- **Ingress-NGINX**: Ingress controller for traffic routing
- **Cert-Manager**: Automatic SSL certificate management (Let's Encrypt)
- **ArgoCD**: GitOps continuous deployment
- **Monitoring Stack**:
  - Prometheus: Metrics collection
  - Grafana: Metrics visualization
  - Loki: Log aggregation
  - Promtail: Log collection
  - OpenTelemetry Collector: Distributed tracing

### Application Stack (via ArgoCD)
- **CloudKart Deployment**: Multi-replicas with health checks
- **MongoDB**: Persistent database with PV/PVC
- **ConfigMaps & Secrets**: Environment configuration
- **Horizontal Pod Autoscaling**: Auto-scaling based on metrics
- **Ingress**: TLS-enabled ingress with cert-manager

---

## 🚀 Quick Start

### Prerequisites
```bash
# Install required tools
brew install terraform awscli kubectl helm  # macOS
# or
apt-get install terraform awscli kubectl helm  # Ubuntu/Debian

# Configure AWS credentials
aws configure
# OR set environment variables:
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### Deploy Infrastructure

```bash
# 1. Initialize Terraform (download providers & modules)
terraform init

# 2. Review what will be created
terraform plan

# 3. Apply configuration (deploy to AWS)
terraform apply

# 4. When prompted, provide your GitHub token:
# (Needed for ArgoCD to sync your Git repository)
TF_VAR_github_token="your-pat-token" terraform apply
```

### Post-Deployment

```bash
# 1. Update kubeconfig
aws eks update-kubeconfig --region eu-west-1 --name cloudkart-eks-cluster

# 2. Verify cluster is ready
kubectl get nodes
kubectl get namespaces

# 3. Check Helm releases
helm list -a --all-namespaces

# 4. Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode

# 5. Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8443:443
# Visit https://localhost:8443 (username: admin, password from step 4)

# 6. Monitor CloudKart deployment
kubectl get deployments -n cloudkart
kubectl logs -f deployment/cloudkart -n cloudkart
```

---

## 📁 Directory Structure

```
terraform/
├── provider.tf              # AWS, Kubernetes, Helm providers
├── variables.tf             # Configuration variables
├── vpc.tf                  # VPC module setup
├── eks.tf                  # EKS cluster configuration
├── ec2.tf                  # Jenkins EC2 instance
├── helm.tf                 # Helm chart installations
├── argocd.tf               # ArgoCD setup & App-of-Apps
├── outputs.tf              # Output values (IPs, endpoints, etc.)
├── install_tools.sh        # User data script for Jenkins
├── cloudkart-key.pub       # SSH public key
└── .terraform/             # Provider binaries & state (auto-managed)
```

---

## 🔧 Configuration Variables

All variables are defined in `variables.tf`. Key variables:

```hcl
# AWS Configuration
variable "aws_region"           # Default: eu-west-1
variable "environment"          # Default: prod

# EKS Node Group
variable "node_instance_type"   # Default: c7i-flex.large (burstable)
variable "node_min_size"        # Default: 2
variable "node_max_size"        # Default: 4
variable "node_desired_size"    # Default: 2

# Jenkins EC2
variable "jenkins_instance_type" # Default: c7i-flex.large
variable "jenkins_volume_size"   # Default: 20GB

# GitHub (for ArgoCD automation)
variable "github_repo_url"           # Your repo URL
variable "github_repo_username"      # Your GitHub username
variable "github_token"              # YOUR GITHUB PAT (set via env var)
```

### Override Defaults

```bash
# Method 1: Environment variables
export TF_VAR_node_desired_size=3
export TF_VAR_github_token="your-token"
terraform apply

# Method 2: Command-line flags
terraform apply -var="node_desired_size=3" -var="github_token=your-token"

# Method 3: Create terraform.tfvars file
cat > terraform.tfvars <<EOF
node_desired_size = 3
github_token = "your-token"
EOF
terraform apply
```

---

## 💰 Cost Estimation

### Monthly Costs (eu-west-1 region):
- **EKS Cluster**: ~$73 (flat rate)
- **EC2 Nodes**: 2x c7i-flex.large (SPOT) ≈ $50-100/month
- **Jenkins EC2**: 1x c7i-flex.large ≈ $50-80/month
- **Data Transfer**: ~$10-30/month
- **Storage (EBS)**: ~$10-20/month
- **Load Balanced Endpoints**: ~$16/month

**Total**: ~$200-300/month (varies by usage)

---

## 🔐 Security Considerations

### Best Practices Implemented:
✅ Private subnets for EKS control plane  
✅ Security groups with minimal CIDR blocks  
✅ RBAC enabled in EKS  
✅ Secrets encrypted in Kubernetes  
✅ TLS for Ingress traffic  

---

## ⚖️ License

This Terraform configuration is part of CloudKart project. See LICENSE file.

---

**Last Updated**: April 28, 2026  
**Terraform Version**: >= 1.5.0
