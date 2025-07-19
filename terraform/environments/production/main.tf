terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  cluster_name         = var.cluster_name
  environment          = var.environment
  vpc_cidr            = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
  
  cluster_name = var.cluster_name
  environment  = var.environment
}

# EKS Module
module "eks" {
  source = "../../modules/eks"
  
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  environment               = var.environment
  private_subnet_ids        = module.vpc.private_subnet_ids
  cluster_service_role_arn  = module.iam.cluster_service_role_arn
  node_group_role_arn       = module.iam.node_group_role_arn
  gpu_instance_types        = var.gpu_instance_types
  gpu_node_min_size         = var.gpu_node_min_size
  gpu_node_max_size         = var.gpu_node_max_size
  gpu_node_desired_size     = var.gpu_node_desired_size
}
