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
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
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
    iam_role_additional_policies = {
      AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
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

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}