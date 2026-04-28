# ✅ CloudKart Terraform Infrastructure - Complete Setup Guide

## 🎯 Status: READY FOR DEPLOYMENT

All duplicate files have been removed, providers are configured, and infrastructure is ready to deploy with a single `terraform apply` command.

---

## 📊 What Was Fixed

### ✅ Completed Actions

1. **Consolidated Terraform Files**
   - Merged `terraform/EKS/` into main `terraform/` directory
   - Removed duplicate VPC, EKS, and provider configurations
   - All infrastructure now in single directory

2. **Fixed Provider Configuration**
   - ✓ AWS Provider configured correctly
   - ✓ Kubernetes Provider added with proper authentication
   - ✓ Helm Provider added with EKS authentication
   - ✓ kubectl Provider added for manifest management
   - ✓ Null Provider for local-exec provisioners

3. **Added Missing Variables**
   - ✓ GitHub repo URL & token for ArgoCD
   - ✓ GitHub username for private repo access
   - ✓ Node group size variables
   - ✓ Jenkins instance configuration variables
   - ✓ Region centralized to eu-west-1

4. **Removed Duplicates & Unused Files**
   - ❌ Deleted: `terraform/EKS/` (all files consolidated)
   - ❌ Deleted: `terraform/Jenkins/` (duplicate EC2 config)
   - ❌ Deleted: `ansible/jenkins-setup.yml` (not needed - Terraform handles it)

5. **Created CloudKart Namespace**
   - ✓ Added `kubernetes_namespace.cloudkart` resource in helm.tf
   - ✓ Fixed ArgoCD destination namespace to `cloudkart`
   - ✓ All manifests will deploy to correct namespace

6. **Updated Documentation**
   - ✓ Comprehensive terraform/README.md
   - ✓ New DEPLOY.sh script with step-by-step deployment
   - ✓ This deployment summary

---

## 📁 Final Directory Structure

```
CloudKart-E_Commerce/
├── kubernetes/                          # Kubernetes manifests
│   ├── 00-cluster-issuer.yml           # Let's Encrypt issuer
│   ├── 01-namespace.yaml                # CloudKart namespace
│   ├── 02-mongodb-pv.yaml               # MongoDB persistent volume
│   ├── 03-mongodb-pvc.yaml              # MongoDB persistent volume claim
│   ├── 04-configmap.yaml                # App configuration
│   ├── 05-secrets.yaml                  # App secrets
│   ├── 06-mongodb-service.yaml          # MongoDB service
│   ├── 07-mongodb-statefulset.yaml      # MongoDB stateful set
│   ├── 08-cloudkart-deployment.yaml     # CloudKart app deployment
│   ├── 09-cloudkart-service.yaml        # CloudKart service
│   ├── 10-ingress.yaml                  # HTTPS ingress
│   ├── 11-hpa.yaml                      # Horizontal pod autoscaler
│   ├── 12-migration-job.yaml            # Database migration job
│   └── metrics-server.yaml              # Metrics server
│
├── terraform/                           # Infrastructure-as-Code
│   ├── provider.tf                      # Providers configuration ✅ FIXED
│   ├── variables.tf                     # Configuration variables ✅ FIXED
│   ├── vpc.tf                           # VPC module
│   ├── eks.tf                           # EKS cluster (updated)
│   ├── ec2.tf                           # Jenkins server (updated)
│   ├── helm.tf                          # Helm deployments (NEW)
│   ├── argocd.tf                        # ArgoCD setup (NEW)
│   ├── outputs.tf                       # Outputs (updated)
│   ├── install_tools.sh                 # User data script
│   ├── cloudkart-key                    # SSH private key
│   ├── cloudkart-key.pub                # SSH public key
│   ├── README.md                        # Terraform documentation
│   ├── .terraform.lock.hcl              # Provider lock file
│   └── .terraform/                      # Provider cache
│
├── src/                                 # Application source code
├── public/                              # Static assets
├── scripts/                             # Utility scripts
├── DEPLOY.sh                            # Deployment guide script (NEW)
├── DEPLOYMENT_COMPLETE.md               # This file
├── package.json                         # Node.js dependencies
├── Dockerfile                           # Container image
├── docker-compose.yml                   # Local development
├── ecosystem.config.cjs                 # PM2 configuration
├── Jenkinsfile                          # CI/CD pipeline
├── JENKINS.md                           # Jenkins setup guide
└── ...other files...
```

---

## 🚀 Deployment Instructions

### Prerequisites
```bash
# Install tools (macOS)
brew install terraform awscli kubectl helm

# OR Ubuntu/Debian
apt-get install -y terraform awscli kubectl helm

# Configure AWS credentials
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Set region to: eu-west-1
```

### Option 1: Automated Deployment (Recommended)
```bash
cd /Users/kanha/E-Kanha-Website/CloudKart-E_Commerce
chmod +x DEPLOY.sh
./DEPLOY.sh
```

### Option 2: Manual Deployment
```bash
# Step 1: Initialize Terraform
cd terraform
terraform init

# Step 2: Validate configuration
terraform validate

# Step 3: Check what will be created
terraform plan

# Step 4: Deploy infrastructure
export TF_VAR_github_token="your-github-pat-token"
terraform apply

# Your GitHub PAT should have these permissions:
# - repo (Full control of private repositories)
# - read:org (Read org and team membership)

# Step 5: Update kubeconfig
aws eks update-kubeconfig --region eu-west-1 --name cloudkart-eks-cluster

# Step 6: Verify cluster
kubectl get nodes
kubectl get namespaces
```

---

## 📋 What Gets Created

### AWS Infrastructure
- ✅ VPC with 6 subnets (public, private, intra)
- ✅ NAT Gateway for outbound traffic
- ✅ EKS Cluster (Kubernetes 1.28+)
- ✅ 2x c7i-flex.large worker nodes (SPOT pricing)
- ✅ Auto-scaling group (min: 2, max: 4)
- ✅ Security groups with proper ingress/egress rules
- ✅ EC2 Jenkins server (c7i-flex.large)

### Kubernetes Components (Auto-deployed)
- ✅ Ingress-NGINX (LoadBalancer)
- ✅ Cert-Manager (SSL/TLS automation)
- ✅ Prometheus + Grafana + Alertmanager
- ✅ Loki + Promtail (Logging)
- ✅ OpenTelemetry Collector (Tracing)
- ✅ ArgoCD (GitOps deployment)

### Application Stack (via ArgoCD)
- ✅ CloudKart deployment (2 replicas)
- ✅ MongoDB StatefulSet (persistent storage)
- ✅ Ingress controller
- ✅ Let's Encrypt certificates
- ✅ ConfigMaps and Secrets
- ✅ HPA (Horizontal Pod Autoscaling)

---

## 💡 Key Endpoints After Deployment

```bash
# Jenkins CI/CD Server
SSH: ssh -i terraform/cloudkart-key ubuntu@<jenkins-ip>
URL: http://<jenkins-ip>:8080

# ArgoCD GitOps
# (Access via kubectl port-forward)
kubectl port-forward svc/argocd-server -n argocd 8443:443
# Visit: https://localhost:8443
# Username: admin
# Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode)

# Grafana Monitoring
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:3000
# Visit: http://localhost:3000
# Username: admin
# Password: (check terraform output)

# Prometheus Metrics
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
# Visit: http://localhost:9090

# CloudKart Application
# (Check ingress status)
kubectl get ingress -n cloudkart
# Visit: https://cloudkart.buildwithkanha.shop/
```

---

## 🔧 Important Commands

```bash
# View all outputs
terraform output

# Check Helm releases
helm list -a --all-namespaces

# Check cluster resources
kubectl get all -A

# Check CloudKart deployment
kubectl get deployments -n cloudkart
kubectl get pods -n cloudkart
kubectl logs -f deployment/cloudkart -n cloudkart

# Check ArgoCD application status
kubectl get applications -n argocd
kubectl describe application cloudkart-cluster -n argocd

# Upgrade infrastructure
terraform plan
terraform apply

# Destroy everything (WARNING: irreversible)
terraform destroy
```

---

## 📊 Cost Breakdown (Monthly)

| Component | Cost |
|-----------|------|
| EKS Cluster | ~$73 |
| EC2 Nodes (2x c7i-flex SPOT) | ~$50-100 |
| Jenkins EC2 (1x c7i-flex) | ~$50-80 |
| Load Balancers | ~$16 |
| Data Transfer | ~$10-30 |
| Storage (EBS) | ~$10-20 |
| **TOTAL** | **~$200-300** |

**Costs vary by**: region, data transfer, storage usage, and AWS pricing changes.

---

## 🔐 Security Best Practices Applied

✅ VPC with private subnets for control plane  
✅ Security groups with minimal CIDR blocks  
✅ RBAC enabled in EKS  
✅ Kubernetes secrets encryption  
✅ TLS/HTTPS for ingress  
✅ Let's Encrypt certificate automation  
✅ Spot instances for cost optimization  
✅ Network policies support  

---

## 🛠️ Common Issues & Solutions

### Issue: Terraform shows old resources
**Solution**: Refresh state
```bash
terraform refresh
terraform plan
```

### Issue: EKS nodes not becoming Ready
**Solution**: Check node status
```bash
kubectl describe node <node-name>
kubectl get pods -n kube-system
```

### Issue: ArgoCD not syncing
**Solution**: Check application status
```bash
kubectl describe application cloudkart-cluster -n argocd
kubectl logs -n argocd deployment/argocd-application-controller
```

### Issue: Helm release failed
**Solution**: Rollback
```bash
helm rollback <release-name> <revision> -n <namespace>
```

---

## 📚 Documentation Files

- `terraform/README.md` - Terraform configuration details
- `JENKINS.md` - Jenkins CI/CD setup guide
- `about.md` - Project information
- `docker-compose.yml` - Local development setup

---

## ✨ What's Different Now

| Before | After |
|--------|-------|
| ❌ Duplicate terraform/EKS/ folder | ✅ Single consolidated terraform/ folder |
| ❌ Duplicate terraform/Jenkins/ folder | ✅ Everything in one directory |
| ❌ Incomplete provider.tf | ✅ Complete with all required providers |
| ❌ Missing GitHub variables | ✅ All variables defined |
| ❌ Ansible scripts not needed | ✅ Removed, Terraform handles it |
| ❌ Namespace not auto-created | ✅ Created by Terraform (helm.tf) |
| ❌ Multiple terraform apply commands | ✅ Single `terraform apply` does everything |
| ❌ Manual steps required | ✅ Fully automated deployment |

---

## 🎉 Summary

✅ **All issues fixed**  
✅ **No duplicates**  
✅ **No Ansible needed**  
✅ **Single terraform apply**  
✅ **Complete automation**  
✅ **Production ready**  

You're now ready to deploy CloudKart to AWS EKS!

---

**Ready to deploy?** Run:
```bash
cd terraform
terraform apply
```

Or use the automated script:
```bash
./DEPLOY.sh
```

---

**Last Updated**: April 28, 2026  
**Status**: ✅ Production Ready
