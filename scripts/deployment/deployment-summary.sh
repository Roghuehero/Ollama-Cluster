#!/bin/bash

echo " Ollama EKS Cluster Deployment Summary"
echo "========================================"

# Cluster Information
echo " Cluster Information:"
echo "   Cluster Name: $(kubectl config current-context | cut -d'/' -f2)"
echo "   Kubernetes Version: $(kubectl version --short --client | cut -d' ' -f3)"

# Node Information
echo ""
echo "  Nodes:"
kubectl get nodes --no-headers | while read line; do
  echo "   $line"
done

# Ollama Deployment Status
echo ""
echo " Ollama Deployment:"
kubectl get pods -n ollama --no-headers | while read line; do
  echo "   $line"
done

# Services and Ingress
echo ""
echo " Network Configuration:"
kubectl get svc -n ollama --no-headers | while read line; do
  echo "   Service: $line"
done

kubectl get ingress -n ollama --no-headers | while read line; do
  echo "   Ingress: $line"
done

# Load Balancer URL
OLLAMA_URL=$(kubectl get ingress ollama-ingress -n ollama -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ ! -z "$OLLAMA_URL" ]; then
  echo ""
  echo " Access URL: http://$OLLAMA_URL"
  echo "   API Endpoint: http://$OLLAMA_URL/api"
  echo "   Health Check: http://$OLLAMA_URL/api/tags"
fi

# Monitoring
echo ""
echo " Monitoring:"
echo "   Grafana: kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
echo "   Prometheus: kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"

echo ""
echo " Deployment completed successfully!"
echo " Run load tests: python3 scripts/testing/load-test.py http://$OLLAMA_URL"
