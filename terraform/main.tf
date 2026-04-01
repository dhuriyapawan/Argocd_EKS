# --- VPC ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "20.0.0"

  name                 = "my-vpc"
  cidr                 = var.vpc_cidr
  azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets       = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnets      = ["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
}

# --- EKS Cluster ---
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"
  cluster_name    = var.cluster_name
  cluster_version = "1.28"
  subnet_ids      = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      max_size     = 3
      min_size     = 2
      instance_types = ["t3.medium"]
    }
  }
}

# --- ECR Repository ---
resource "aws_ecr_repository" "my_app" {
  name                 = "my-app"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
}