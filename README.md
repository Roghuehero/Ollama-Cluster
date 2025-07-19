#################################################

**1. Provision AWS Infrastructure**
*  cd terraform/environments/production

# Initialize Terraform
*  terraform init

# Validate configuration
* terraform validate

# Plan deployment
* terraform plan -out=tfplan

# Apply infrastructure
* terraform apply tfplan
###########################################################################

**2. Configure Kubernetes CLI**

# Update your kubeconfig for EKS authentication
* aws eks update-kubeconfig --region us-west-2 --name ollama-cluster

# Verify cluster and node access
* kubectl get nodes
* kubectl get namespaces

**3. Install Essential Cluster Components**
# Make the install script executable and run it

1. chmod +x scripts/deployment/install-cluster-components.sh
2. ./scripts/deployment/install-cluster-components.sh

**4. Deploy Kubernetes Resources**

# Deploy Ollama workloads
*kubectl apply -f k8s-manifests/ollama/

# Deploy Ingress (ALB setup)
* kubectl apply -f k8s-manifests/ingress/

# Verify deployments in 'ollama' namespace
* kubectl get all -n ollama
* kubectl get ingress -n ollama

**5. Set Up Monitoring Stack**
# Make the monitoring installer executable and run it
1. chmod +x scripts/deployment/install-monitoring.sh
2. ./scripts/deployment/install-monitoring.sh

**6. Configure CloudWatch Container Insights**
* helm repo add aws-cloudwatch-metrics https://aws.github.io/eks-charts
* helm install aws-cloudwatch-metrics aws-cloudwatch-metrics/aws-cloudwatch-metrics \
  --namespace amazon-cloudwatch \
  --create-namespace \
  --set clusterName=ollama-cluster

**7. Secure Networking**
# Apply network policy for in-cluster communication control
* kubectl apply -f k8s-manifests/ollama/network-policy.yaml

**8. Load Testing and Validation**

# Install required Python library for async load testing
* pip3 install aiohttp

# Make the load-test script executable
* chmod +x scripts/testing/load-test.py

# Get the load balancer URL
* OLLAMA_URL=$(kubectl get ingress ollama-ingress -n ollama -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Run load test: 20 users, 10 requests each
* python3 scripts/testing/load-test.py http://$OLLAMA_URL 20 10

**9. Monitor Scaling Behavior**
# Track the state of pods, nodes, and scaling in real time
* watch kubectl get pods -n ollama
* watch kubectl get hpa -n ollama
* watch kubectl get nodes
* kubectl top pods -n ollama
* kubectl top nodes

**10. Access Monitoring Dashboards**

# Port-forward to Grafana (web dashboard)
* kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Port-forward to Prometheus
* kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Grafana: http://localhost:3000  (username: admin, password: admin123)
# Prometheus: http://localhost:9090

**11. API Endpoint Testing**

# Load balancer URL for Ollama API
* OLLAMA_URL=$(kubectl get ingress ollama-ingress -n ollama -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test models listing endpoint
* curl -X GET http://$OLLAMA_URL/api/tags

# Test model inference endpoint
curl -X POST http://$OLLAMA_URL/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemma2:9b",
    "prompt": "Explain Kubernetes in simple terms",
    "stream": false
  }'
**12. Deployment Summary & Health**

1. chmod +x scripts/deployment/deployment-summary.sh
2. ./scripts/deployment/deployment-summary.sh
