module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Network configuration
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Cluster endpoint access
  cluster_endpoint_public_access       = true
  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access_cidrs = var.allowed_cidr_blocks

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  # EKS Managed Node Groups
  eks_managed_node_groups = {
    general = {
      name            = "${var.project_name}-node-group"
      use_name_prefix = true

      subnet_ids = module.vpc.private_subnets

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      instance_types = var.node_instance_types
      capacity_type  = "ON_DEMAND"

      disk_size = var.node_disk_size

      # Launch template configuration
      create_launch_template = true
      launch_template_name   = "${var.project_name}-node-lt"

      labels = {
        Environment = var.environment
        NodeGroup   = "general"
      }

      tags = {
        Name = "${var.project_name}-eks-node"
      }

      # Enable IMDSv2
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
      }
    }
  }

  # Cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Nodes on ephemeral ports"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Node security group rules
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Enable IRSA (IAM Roles for Service Accounts)
  enable_irsa = true

  # Cluster access management
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::954692414134:role/Admin"
      username = "admin"
      groups   = ["system:masters"]
    }
  ]

  tags = {
    Name        = var.cluster_name
    Environment = var.environment
  }
}

# IRSA for VPC CNI
module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "${var.cluster_name}-vpc-cni-"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = {
    Name = "${var.cluster_name}-vpc-cni-irsa"
  }
}

# IRSA for EBS CSI Driver
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "${var.cluster_name}-ebs-csi-"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    Name = "${var.cluster_name}-ebs-csi-irsa"
  }
}

# IRSA for Cluster Autoscaler
module "cluster_autoscaler_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  count = var.enable_cluster_autoscaler ? 1 : 0

  role_name_prefix                 = "${var.cluster_name}-cluster-autoscaler-"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = {
    Name = "${var.cluster_name}-cluster-autoscaler-irsa"
  }
}

# IRSA for AWS Load Balancer Controller
module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  count = var.enable_aws_load_balancer_controller ? 1 : 0

  role_name_prefix                       = "${var.cluster_name}-lb-controller-"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = {
    Name = "${var.cluster_name}-lb-controller-irsa"
  }
}
