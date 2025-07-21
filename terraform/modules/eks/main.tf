# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_service_role_arn
  
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }
  
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  
  tags = {
    Environment = var.environment
  }
}

# EKS Node Group for System Workloads
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "system-nodes"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnet_ids
  
  instance_types = ["m5.large"]
  capacity_type  = "ON_DEMAND"
  
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  
  update_config {
    max_unavailable = 1
  }
  
  labels = {
    role = "system"
  }
  
  taint {
    key    = "system"
    value  = "true"
    effect = "NO_SCHEDULE"
  }
}

# EKS Node Group for GPU Workloads
resource "aws_eks_node_group" "gpu" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "gpu-nodes"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnet_ids
  
  ami_type       = "AL2_x86_64_GPU"
  instance_types = var.gpu_instance_types
  capacity_type  = "ON_DEMAND"
  
  scaling_config {
    desired_size = var.gpu_node_desired_size
    max_size     = var.gpu_node_max_size
    min_size     = var.gpu_node_min_size
  }
  
  update_config {
    max_unavailable = 1
  }
  
  labels = {
    role = "gpu"
    "nvidia.com/gpu" = "true"
  }
  
  taint {
    key    = "nvidia.com/gpu"
    value  = "true"
    effect = "NO_SCHEDULE"
  }
}
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "cluster_service_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  type        = string
}

variable "node_group_role_arn" {
  description = "IAM role ARN for the EKS node groups"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS"
  type        = list(string)
}

variable "gpu_instance_types" {
  description = "List of GPU instance types for the GPU node group"
  type        = list(string)
}

variable "gpu_node_desired_size" {
  description = "Desired number of GPU nodes"
  type        = number
}

variable "gpu_node_min_size" {
  description = "Minimum number of GPU nodes"
  type        = number
}

variable "gpu_node_max_size" {
  description = "Maximum number of GPU nodes"
  type        = number
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}
