**Ollama EKS Cluster Provisioning Guide**
This guide details the professional steps required to provision a secure, scalable Ollama cluster on AWS EKS using Infrastructure-as-Code (Terraform) and Kubernetes.

**Prerequisites**

1. AWS Account with required IAM permissions
2. Linux/macOS terminal with sudo privileges
3. Your AWS Access Key ID and Secret Access Key

1. **Install Required Tools**
     
# Install Terraform
1. curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
2. sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
3. sudo apt update && sudo apt install terraform

# Install kubectl
1. curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
2. sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
1. curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
2. echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all   main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
3. sudo apt update && sudo apt install helm

# Install AWS CLI
1. curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
2. unzip awscliv2.zip && sudo ./aws/install
   
**3. Configure AWS CLI**

3.1 aws configure
# Enter your AWS Access Key ID, Secret Access Key, default region (e.g., us-west-2), and output format (json)

3.2 aws sts get-caller-identity
# Verify credentials are correct; this should return your AWS account and user info

**Set Up Project Directory Structure**

1. mkdir -p ollama-eks-cluster/{terraform/{modules/{vpc,eks,iam},environments/production},k8s- manifests/{ollama,monitoring,ingress},scripts/{deployment,testing},monitoring}
2. cd ollama-eks-cluster
   
**4. Infrastructure Provisioning**

1. cd terraform/environments/production
2. terraform init
3. terraform validate
4. terraform plan -out=tfplan
5. terraform apply tfplan

**Configure kubectl Access for EKS**

1. aws eks update-kubeconfig --region us-west-2 --name ollama-cluster
2. kubectl get nodes

**Install EKS Add-ons**

1 .Install with Helm or kubectl
2. AWS Load Balancer Controller
3. NVIDIA Device Plugin
4. Metrics Server
5. Cluster Autoscaler

# Example: Install NVIDIA Device Plugin
1. kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.0/nvidia-device-plugin.yml
(Other manifests/scripts can go under scripts/deployment/.)

**5. Application & Monitoring Deployment**
5.1. Namespaces & Storage

1. kubectl apply -f k8s-manifests/ollama/namespace.yaml
2. kubectl apply -f k8s-manifests/ollama/persistent-volume.yaml

**5.2. Ollama StatefulSet**
1. kubectl apply -f k8s-manifests/ollama/deployment.yaml
   
**5.3. Service & Ingress**

1. kubectl apply -f k8s-manifests/ingress/ingress.yaml

**5.4. Monitoring Stack**

1. kubectl create namespace monitoring
2. helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
3. helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring

**6. Security Hardening**

1. Use Security Groups for ALB and nodes.
2. Grant least-privilege IAM roles to services and node groups.
3.Enable Kubernetes Network Policies for pod isolation.
4. Secure all ingress with TLS/SSL certificates.
5. Store sensitive data with AWS Secrets Manager.

**7. Validation**

1. kubectl get pods -n ollama
2. kubectl get nodes
3. kubectl get hpa -n ollama

# Get ALB DNS and test API endpoint:
1. kubectl get ingress -n ollama
2. curl https://<your-alb-dns>/api/tags

**8. Load Testing**

1. Build or use a script to simulate concurrent user requests and trigger scaling.

**9. Tear Down & Clean Up**
1. terraform destroy
