# AWS Configuration
variable "aws_region" {
  description = "AWS region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

# EKS Configuration
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
}

variable "gpu_instance_types" {
  description = "List of GPU EC2 instance types for EKS nodes"
  type        = list(string)
}

variable "gpu_node_min_size" {
  description = "Minimum size of the GPU node group"
  type        = number
}

variable "gpu_node_max_size" {
  description = "Maximum size of the GPU node group"
  type        = number
}

variable "gpu_node_desired_size" {
  description = "Desired size of the GPU node group"
  type        = number
}

# Ollama Configuration
variable "ollama_replicas" {
  description = "Number of Ollama replicas to deploy"
  type        = number
}

variable "ollama_num_parallel" {
  description = "Number of parallel tasks for Ollama"
  type        = number
}

variable "domain_name" {
  description = "Domain name for Ollama API"
  type        = string
}
