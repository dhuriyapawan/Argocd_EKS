terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# --- VPC ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "my-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24","10.0.3.0/24"]
  private_subnets = ["10.0.11.0/24","10.0.12.0/24","10.0.13.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true
}

# --- EKS Cluster ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  
name    = "my-cluster-v3"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  #cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      desired_size   = 2
      min_size       = 2
      max_size       = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      ami_type           = "AL2_x86_64"
      kubernetes_version = "1.31"
    }
  }
}

# --- ECR Repository ---
resource "aws_ecr_repository" "my_app" {
  name                 = var.cluster_name
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}