# ============================================================
# AWS & GENERAL VARIABLES
# ============================================================
variable "aws_region" {
  description = "AWS region where resources will be provisioned"
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (dev, prod, staging)"
  default     = "prod"
}

# ============================================================
# EKS NODE GROUP VARIABLES
# ============================================================
variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  default     = "c7i-flex.large"
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  default     = 4
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  default     = 2
}

# ============================================================
# JENKINS EC2 VARIABLES
# ============================================================
variable "jenkins_instance_type" {
  description = "Instance type for Jenkins EC2"
  default     = "c7i-flex.large"
}

variable "jenkins_volume_size" {
  description = "Root volume size for Jenkins EC2 (GB)"
  default     = 20
}

variable "jenkins_key_name" {
  description = "EC2 Key pair name for Jenkins"
  default     = "cloudkart-key"
}

# ============================================================
# GITHUB VARIABLES (For ArgoCD)
# ============================================================
variable "github_repo_url" {
  description = "GitHub repo URL for ArgoCD to sync from"
  default     = "https://github.com/kanhaiyatiwari/CloudKart-E_Commerce"
}

variable "github_repo_username" {
  description = "GitHub username for private repo access"
  default     = "kanhaiyatiwari"
}

variable "github_token" {
  description = "GitHub Personal Access Token for private repo access"
  type        = string
  sensitive   = true
  default     = ""
}