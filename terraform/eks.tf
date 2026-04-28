module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  cluster_timeouts = {
    delete = "2h"
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types                        = [var.node_instance_type]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    cloudkart-ng = {
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      instance_types = [var.node_instance_type]
      capacity_type  = "SPOT"

      disk_size                  = 35
      use_custom_launch_template = false

      labels = {
        role        = "worker"
        environment = local.environment
      }

      tags = {
        Name                                      = "cloudkart-ng"
        Environment                               = local.environment
        "k8s.io/cluster-autoscaler/enabled"       = "true"
        "k8s.io/cluster-autoscaler/${local.name}" = "owned"
      }
    }
  }

  tags       = local.tags
  depends_on = [module.vpc]
}

# Fetch node instance IPs after cluster is ready
data "aws_instances" "eks_nodes" {
  instance_tags = {
    "eks:cluster-name" = module.eks.cluster_name
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [module.eks]
}