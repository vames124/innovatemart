#!/bin/bash
set -e

echo "========================================"
echo "Project Bedrock - Infrastructure Teardown"
echo "========================================"
echo ""
echo "WARNING: This will destroy ALL resources!"
echo "Press Ctrl+C within 10 seconds to abort..."
sleep 10

echo ""
echo "[1/5] Deleting Kubernetes resources..."
kubectl delete ingress --all -n retail-app --ignore-not-found 2>/dev/null || true
echo "Waiting 30s for ALB cleanup..."
sleep 30
kubectl delete -f kubernetes/deployments/ --ignore-not-found 2>/dev/null || true
kubectl delete -f kubernetes/services/ --ignore-not-found 2>/dev/null || true
kubectl delete -f kubernetes/secrets/ --ignore-not-found 2>/dev/null || true
kubectl delete -f kubernetes/service-accounts/ --ignore-not-found 2>/dev/null || true
kubectl delete -f kubernetes/rbac/ --ignore-not-found 2>/dev/null || true
kubectl delete namespace retail-app --ignore-not-found 2>/dev/null || true

echo ""
echo "[2/5] Removing Helm releases..."
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || true
sleep 15

echo ""
echo "[3/5] Emptying S3 buckets..."
aws s3 rm s3://bedrock-assets-alt-soe-025-4486 --recursive 2>/dev/null || true

echo ""
echo "[4/5] Destroying Terraform infrastructure..."
cd terraform
terraform init
terraform destroy -auto-approve

echo ""
echo "[5/5] Removing state bucket..."
aws s3 rm s3://project-bedrock-tfstate-alt-soe-025-4486 --recursive 2>/dev/null || true
aws s3api delete-bucket --bucket project-bedrock-tfstate-alt-soe-025-4486 --region us-east-1 2>/dev/null || true

echo ""
echo "========================================"
echo "Teardown complete! All resources destroyed."
echo "========================================"
