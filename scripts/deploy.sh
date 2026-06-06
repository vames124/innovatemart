#!/bin/bash
set -e

echo "========================================"
echo "Project Bedrock - Deployment Script"
echo "========================================"

# ── Step 1: Create Terraform state bucket ──
echo ""
echo "[1/9] Creating Terraform state bucket..."
aws s3api create-bucket \
  --bucket project-bedrock-tfstate-alt-soe-025-4486 \
  --region us-east-1 2>/dev/null || echo "Bucket already exists."

aws s3api put-bucket-versioning \
  --bucket project-bedrock-tfstate-alt-soe-025-4486 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-tagging \
  --bucket project-bedrock-tfstate-alt-soe-025-4486 \
  --tagging 'TagSet=[{Key=Project,Value=karatu-2025-capstone}]'

# ── Step 2: Terraform Init & Plan ──
echo ""
echo "[2/9] Initializing Terraform..."
cd terraform
terraform init
terraform plan -out=tfplan

echo ""
read -p "Review the plan above. Apply? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

# ── Step 3: Terraform Apply ──
echo ""
echo "[3/9] Applying Terraform..."
terraform apply tfplan

# ── Step 4: Get outputs ──
echo ""
echo "[4/9] Retrieving infrastructure outputs..."
MYSQL_EP=$(terraform output -raw mysql_endpoint)
POSTGRES_EP=$(terraform output -raw postgres_endpoint)
VPC_ID=$(terraform output -raw vpc_id)
echo "  MySQL Endpoint:    $MYSQL_EP"
echo "  Postgres Endpoint: $POSTGRES_EP"
echo "  VPC ID:            $VPC_ID"

# ── Step 5: Configure kubectl ──
echo ""
echo "[5/9] Configuring kubectl..."
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# ── Step 6: Create namespace and RBAC ──
echo ""
echo "[6/9] Creating namespace, RBAC, and service accounts..."
cd ..
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/rbac/
kubectl apply -f kubernetes/service-accounts/

# ── Step 7: Install AWS Load Balancer Controller ──
echo ""
echo "[7/9] Installing AWS Load Balancer Controller..."
helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=project-bedrock-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=$VPC_ID

# ── Step 8: Create secrets and deploy app ──
echo ""
echo "[8/9] Creating secrets and deploying application..."

# Create catalog DB secret
kubectl create secret generic catalog-db-credentials \
  --namespace retail-app \
  --from-literal=DB_ENDPOINT="$MYSQL_EP" \
  --from-literal=DB_PORT="3306" \
  --from-literal=DB_NAME="catalog" \
  --from-literal=DB_USER="catalog_admin" \
  --from-literal=DB_PASSWORD="CatalogSecure2025!" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create orders DB secret
kubectl create secret generic orders-db-credentials \
  --namespace retail-app \
  --from-literal=SPRING_DATASOURCE_URL="jdbc:postgresql://$POSTGRES_EP:5432/orders" \
  --from-literal=SPRING_DATASOURCE_USERNAME="orders_admin" \
  --from-literal=SPRING_DATASOURCE_PASSWORD="OrdersSecure2025!" \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy services
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/

# ── Step 9: Wait for pods and get URL ──
echo ""
echo "[9/9] Waiting for pods to be ready (up to 5 min)..."
kubectl wait --for=condition=available deployment --all -n retail-app --timeout=300s || true

echo ""
echo "========================================"
echo "Deployment Summary"
echo "========================================"
echo ""
echo "Pods:"
kubectl get pods -n retail-app
echo ""
echo "Services:"
kubectl get svc -n retail-app
echo ""
echo "Ingress (ALB URL):"
kubectl get ingress -n retail-app
echo ""

# Generate grading output
echo "Generating grading.json..."
cd terraform
terraform output -json > ../grading.json

echo ""
echo "========================================"
echo "Deployment complete!"
echo "NOTE: ALB may take 2-3 minutes to provision."
echo "Run: kubectl get ingress -n retail-app"
echo "========================================"
