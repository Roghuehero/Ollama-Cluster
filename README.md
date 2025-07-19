# Ollama-Cluster

**Step 1** **Required Tools**

# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update && sudo apt install helm

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

Step 2: Configure AWS Credentials
bash
# Configure AWS CLI with your credentials
aws configure
# Enter your Access Key ID, Secret Access Key, Region (us-west-2), and output format (json)

# Verify configuration
aws sts get-caller-identity


Step 3: Create Project Directory Structure
bash
mkdir -p ollama-eks-cluster/{terraform,k8s-manifests,scripts,monitoring}
cd ollama-eks-cluster

# Create directory structure
mkdir -p terraform/{modules/{vpc,eks,iam},environments/production}
mkdir -p k8s-manifests/{ollama,monitoring,ingress}
mkdir -p scripts/{deployment,testing}
