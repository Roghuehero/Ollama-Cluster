resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-eks-cluster-role"
    Environment = var.environment
  }
}

resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}-${var.environment}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "${var.cluster_name}-node-group-role"
    Environment = var.environment
  }
}
variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g., dev, prod)"
}
