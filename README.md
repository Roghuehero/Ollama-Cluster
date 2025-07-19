Ollama EKS Cluster Provisioning Guide
This guide will walk you through the professional and modular steps required to provision a secure, scalable Ollama cluster on AWS EKS using Infrastructure-as-Code (IaC). Follow these steps to set up your environment, deploy the infrastructure, and prepare for LLM serving with best practices in automation and security.

Prerequisites
AWS Account with admin/appropriate IAM permissions.

Linux/macOS Machine with sudo privileges.

User's AWS Access Key & Secret.

1. Toolchain Installation
Install and verify the core tools required for IaC provisioning and Kubernetes application management.

Terraform
bash
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt update && sudo apt install terraform
kubectl
bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
Helm
bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update && sudo apt install helm
AWS CLI
bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install
2. AWS CLI Configuration
Configure CLI access and verify that your credentials are correct.

bash
aws configure
# Provide Access Key, Secret Key, region (us-west-2), output (json)
aws sts get-caller-identity
3. Project Structure
Organize your code into clear, maintainable directories for Terraform modules, manifests, and scripts.

bash
mkdir -p ollama-eks-cluster/{terraform/{modules/{vpc,eks,iam},environments/production},k8s-manifests/{ollama,monitoring,ingress},scripts/{deployment,testing},monitoring}
cd ollama-eks-cluster
4. Infrastructure Provisioning Steps
4.1. Prepare Terraform Variable Files
Edit terraform/environments/production/terraform.tfvars to set basic parameters:

text
aws_region         = "us-west-2"
environment        = "production"
cluster_name       = "ollama-cluster"
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
Customize other values as needed (see README for all variables).

4.2. Deploy the VPC, EKS, and Dependencies
bash
cd terraform/environments/production

terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
4.3. Configure kubectl Access for EKS
bash
aws eks update-kubeconfig --region us-west-2 --name ollama-cluster
kubectl get nodes
4.4. Install EKS Add-ons
AWS Load Balancer Controller

NVIDIA Device Plugin

Metrics Server

Cluster Autoscaler

Use Helm and/or kubectl apply with official YAMLs or scripts you maintain in scripts/deployment.

5. Application & Monitoring Deployment
5.1. Namespace & Persistent Volume Claims
Apply manifests in k8s-manifests/ollama/ for your:

Kubernetes namespace

PersistentVolumes and PVCs (EBS-backed for model storage)

bash
kubectl apply -f k8s-manifests/ollama/namespace.yaml
kubectl apply -f k8s-manifests/ollama/persistent-volume.yaml
5.2. Ollama StatefulSet Deployment
Apply the StatefulSet manifest to schedule pods on GPU nodes and ensure model pre-loading.

bash
kubectl apply -f k8s-manifests/ollama/deployment.yaml
5.3. Ingress & Service
Expose the Ollama API securely using your ALB ingress manifest.

bash
kubectl apply -f k8s-manifests/ingress/ingress.yaml
5.4. Monitoring Stack
Provision monitoring with Helm or manifests:

bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring
6. Security Hardening
Use Security Groups for ALB and compute nodes.

Enforce least-privilege IAM roles for EKS and node group access.

Apply Kubernetes Network Policies for pod isolation.

Enable TLS/SSL everywhere user traffic enters.

Store sensitive data (API keys, DB passwords) in AWS Secrets Manager.

7. Cluster Validation
Check Pod Status:
kubectl get pods -n ollama

List Nodes:
kubectl get nodes

Test ALB Ingress:
curl https://<your-alb-dns>/api/tags

Monitor Scaling:
kubectl get hpa -n ollama

8. Load Testing (Optional)
Create and use a load testing script (e.g., Python with aiohttp) to simulate concurrent users, verify scaling, and ensure low latency under expected workloads.

9. Clean Up Resources
To avoid unwanted AWS charges, destroy the provisioned infrastructure when not needed:

bash
terraform destroy
