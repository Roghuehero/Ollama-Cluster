# AWS Configuration
aws_region = "us-west-2"
environment = "production"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# VPC Configuration
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]

# EKS Configuration
cluster_name = "ollama-cluster"
cluster_version = "1.28"
gpu_instance_types = ["g5.2xlarge", "g5.4xlarge"]
gpu_node_min_size = 1
gpu_node_max_size = 10
gpu_node_desired_size = 2

# Ollama Configuration
ollama_replicas = 3
ollama_num_parallel = 4
domain_name = "ollama-api.test.com"
