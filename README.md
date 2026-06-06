# 🏗️ Project Bedrock — InnovateMart EKS Infrastructure

> Production-Grade Microservices on Amazon EKS | Cloud DevOps Capstone Project

## 📋 Overview

Project Bedrock provisions a fully automated, production-grade Kubernetes infrastructure on AWS for InnovateMart's Retail Store Application. The entire infrastructure is defined as code using Terraform and deployed via CI/CD.

| Resource | Value |
|---|---|
| **AWS Region** | `us-east-1` (N. Virginia) |
| **EKS Cluster** | `project-bedrock-cluster` (v1.31) |
| **VPC** | `project-bedrock-vpc` (10.0.0.0/16) |
| **App Namespace** | `retail-app` |
| **Developer IAM User** | `bedrock-dev-view` |
| **S3 Assets Bucket** | `bedrock-assets-alt-soe-025-4486` |
| **Lambda Function** | `bedrock-asset-processor` |
| **Resource Tag** | `Project: karatu-2025-capstone` |

---

## 🏛️ Architecture

```
┌─────────────────────────────── AWS Cloud (us-east-1) ───────────────────────────────┐
│                                                                                      │
│  ┌─────────────────── VPC: project-bedrock-vpc (10.0.0.0/16) ───────────────────┐   │
│  │                                                                                │   │
│  │  ┌─── Public Subnet (us-east-1a) ───┐  ┌─── Public Subnet (us-east-1b) ───┐  │   │
│  │  │  NAT Gateway                      │  │                                   │  │   │
│  │  │  ALB (Internet-facing)            │  │  ALB (target)                     │  │   │
│  │  └──────────────────────────────────┘  └───────────────────────────────────┘  │   │
│  │                                                                                │   │
│  │  ┌── Private Subnet (us-east-1a) ──┐  ┌── Private Subnet (us-east-1b) ──┐   │   │
│  │  │                                  │  │                                  │   │   │
│  │  │  ┌──────── EKS Cluster ────────────────────────────────────┐          │   │   │
│  │  │  │  Namespace: retail-app                                   │          │   │   │
│  │  │  │  ┌────┐ ┌────────┐ ┌────┐ ┌──────┐ ┌────────┐         │          │   │   │
│  │  │  │  │ UI │ │Catalog │ │Cart│ │Orders│ │Checkout│         │          │   │   │
│  │  │  │  └────┘ └────────┘ └────┘ └──────┘ └────────┘         │          │   │   │
│  │  │  │  ┌────────┐ ┌─────┐                                    │          │   │   │
│  │  │  │  │RabbitMQ│ │Redis│  (in-cluster)                      │          │   │   │
│  │  │  │  └────────┘ └─────┘                                    │          │   │   │
│  │  │  └─────────────────────────────────────────────────────────┘          │   │   │
│  │  │                                  │  │                                  │   │   │
│  │  │  ┌──── RDS MySQL ──────────────────── RDS PostgreSQL ──┐              │   │   │
│  │  │  │  catalog DB                   │  │  orders DB        │              │   │   │
│  │  │  └──────────────────────────────────────────────────────┘              │   │   │
│  │  └──────────────────────────────────┘  └──────────────────────────────────┘   │   │
│  └────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
│  ┌── DynamoDB ──┐    ┌── S3 Bucket ──────────────┐    ┌── Lambda ──────────────┐   │
│  │ Cart Table    │    │ bedrock-assets-*           │───▶│ bedrock-asset-processor│   │
│  └──────────────┘    └───────────────────────────┘    └────────────────────────┘   │
│                                                                                      │
│  ┌── CloudWatch ─────────────────────────────────────────────────────────────────┐   │
│  │ Control Plane Logs │ Container Logs (Observability Add-on) │ Lambda Logs      │   │
│  └───────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                      │
│  ┌── IAM ──────────────────────────────────────────────────────────────────┐         │
│  │ bedrock-dev-view (ReadOnly + K8s view + S3 PutObject)                   │         │
│  │ Cart IRSA Role (DynamoDB access)                                         │         │
│  │ CloudWatch IRSA Role                                                     │         │
│  │ LB Controller IRSA Role                                                  │         │
│  └─────────────────────────────────────────────────────────────────────────┘         │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| AWS CLI | v2.x | [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |
| Terraform | >= 1.9.0 | [Install Guide](https://developer.hashicorp.com/terraform/install) |
| kubectl | >= 1.28 | [Install Guide](https://kubernetes.io/docs/tasks/tools/) |
| Helm | >= 3.x | [Install Guide](https://helm.sh/docs/intro/install/) |
| Git | latest | [Install Guide](https://git-scm.com/downloads) |

Ensure AWS CLI is configured: `aws configure` (use `us-east-1` region)

---

## 🚀 Quick Start Deployment

### Option A: Automated Script (Recommended)

```bash
# Clone and enter the repo
git clone <your-repo-url>
cd project-bedrock

# Run the deployment script
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### Option B: Step-by-Step Manual

#### 1. Create Terraform State Bucket

```bash
aws s3api create-bucket \
  --bucket project-bedrock-tfstate-alt-soe-025-4486 \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket project-bedrock-tfstate-alt-soe-025-4486 \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-tagging \
  --bucket project-bedrock-tfstate-alt-soe-025-4486 \
  --tagging 'TagSet=[{Key=Project,Value=karatu-2025-capstone}]'
```

#### 2. Terraform Init, Plan & Apply

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

#### 3. Configure kubectl

```bash
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1
```

#### 4. Deploy Kubernetes Resources

```bash
# Namespace and RBAC
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/rbac/
kubectl apply -f kubernetes/service-accounts/

# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm repo update
VPC_ID=$(cd terraform && terraform output -raw vpc_id)
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=project-bedrock-cluster \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=us-east-1 \
  --set vpcId=$VPC_ID

# Create database secrets (replace endpoints from terraform output)
MYSQL_EP=$(cd terraform && terraform output -raw mysql_endpoint)
POSTGRES_EP=$(cd terraform && terraform output -raw postgres_endpoint)

kubectl create secret generic catalog-db-credentials \
  --namespace retail-app \
  --from-literal=DB_ENDPOINT="$MYSQL_EP" \
  --from-literal=DB_PORT="3306" \
  --from-literal=DB_NAME="catalog" \
  --from-literal=DB_USER="catalog_admin" \
  --from-literal=DB_PASSWORD="CatalogSecure2025!" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic orders-db-credentials \
  --namespace retail-app \
  --from-literal=SPRING_DATASOURCE_URL="jdbc:postgresql://$POSTGRES_EP:5432/orders" \
  --from-literal=SPRING_DATASOURCE_USERNAME="orders_admin" \
  --from-literal=SPRING_DATASOURCE_PASSWORD="OrdersSecure2025!" \
  --dry-run=client -o yaml | kubectl apply -f -

# Deploy app
kubectl apply -f kubernetes/deployments/
kubectl apply -f kubernetes/services/
kubectl apply -f kubernetes/ingress/
```

#### 5. Verify

```bash
kubectl get pods -n retail-app
kubectl get ingress -n retail-app
```

---

## 🌐 Accessing the Application

After deployment, get the ALB URL:

```bash
kubectl get ingress -n retail-app -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'
```

Open the hostname in your browser. The ALB may take 2-3 minutes to provision.

---

## 📊 Grading Output

Generate the required `grading.json`:

```bash
cd terraform
terraform output -json > ../grading.json
```

This outputs: `cluster_endpoint`, `cluster_name`, `region`, `vpc_id`, `assets_bucket_name`

---

## 🔐 Developer Access (bedrock-dev-view)

Get credentials after Terraform apply:

```bash
# Access Key ID (visible)
terraform output dev_user_access_key_id

# Secret Access Key (sensitive - must use -raw)
terraform output -raw dev_user_secret_access_key

# Console Password (sensitive)
terraform output -raw dev_user_console_password
```

**Console Login URL**: `https://306980977523.signin.aws.amazon.com/console`

**Verification**:
```bash
# Should succeed (read-only):
kubectl get pods -n retail-app

# Should fail (forbidden):
kubectl delete pod <pod-name> -n retail-app
```

---

## 🧪 Testing the Lambda Trigger

```bash
# Upload a test file
echo "test" > test-image.jpg
aws s3 cp test-image.jpg s3://bedrock-assets-alt-soe-025-4486/

# Check Lambda logs
aws logs tail /aws/lambda/bedrock-asset-processor --follow
# Expected: "Image received: test-image.jpg"
```

---

## 🔄 CI/CD Pipeline

| Trigger | Action |
|---------|--------|
| **Pull Request** to `main` | `terraform plan` → posted as PR comment |
| **Push/Merge** to `main` | `terraform apply` → auto-generates `grading.json` |
| **Manual** | Trigger via `workflow_dispatch` |

### Required GitHub Secrets

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS access key for CI/CD |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key for CI/CD |
| `CATALOG_DB_PASSWORD` | Catalog MySQL password |
| `ORDERS_DB_PASSWORD` | Orders PostgreSQL password |

---

## 💰 Cost Management & Teardown

### Estimated Monthly Cost (if running 24/7)

| Resource | Est. Cost |
|----------|-----------|
| EKS Cluster | ~$73/mo |
| NAT Gateway | ~$32/mo |
| 2× t3.medium nodes | ~$60/mo |
| 2× RDS db.t3.micro | ~$30/mo |
| ALB | ~$22/mo |
| **Total** | **~$217/mo** |

### ⚠️ Tear Down All Resources

**Windows (PowerShell):**
```powershell
.\scripts\teardown.ps1
```

**Linux/Mac (Bash):**
```bash
chmod +x scripts/teardown.sh
./scripts/teardown.sh
```

**Manual teardown:**
```bash
# 1. Delete K8s resources (Ingress first to remove ALB)
kubectl delete ingress --all -n retail-app
sleep 30
kubectl delete -f kubernetes/deployments/
kubectl delete -f kubernetes/services/
kubectl delete namespace retail-app

# 2. Remove Helm releases
helm uninstall aws-load-balancer-controller -n kube-system

# 3. Empty S3 buckets
aws s3 rm s3://bedrock-assets-alt-soe-025-4486 --recursive

# 4. Terraform destroy
cd terraform && terraform destroy -auto-approve

# 5. Remove state bucket
aws s3 rm s3://project-bedrock-tfstate-alt-soe-025-4486 --recursive
aws s3api delete-bucket --bucket project-bedrock-tfstate-alt-soe-025-4486
```

> **TIP**: If you only need to pause costs temporarily, scale the EKS node group to 0 and stop RDS instances instead of full teardown.

---

## 📁 Repository Structure

```
project-bedrock/
├── .github/workflows/
│   └── terraform.yaml          # CI/CD pipeline
├── kubernetes/
│   ├── namespace.yaml          # retail-app namespace
│   ├── deployments/            # All service deployments
│   ├── services/               # All ClusterIP services
│   ├── ingress/                # ALB ingress
│   ├── rbac/                   # Developer RBAC binding
│   ├── secrets/                # DB credentials template
│   ├── service-accounts/       # Cart IRSA service account
│   └── aws-lb-controller/     # LB controller Helm values
├── terraform/
│   ├── main.tf                 # Root module
│   ├── variables.tf            # Input variables
│   ├── outputs.tf              # Required outputs
│   ├── backend.tf              # S3 remote state
│   ├── terraform.tfvars        # Variable values
│   └── modules/
│       ├── vpc/                # VPC, subnets, NAT, IGW
│       ├── eks/                # EKS cluster, node groups, OIDC
│       ├── rds/                # MySQL + PostgreSQL instances
│       ├── dynamodb/           # Cart DynamoDB table
│       ├── iam/                # Dev user, IRSA roles
│       ├── serverless/         # S3 + Lambda trigger
│       └── observability/      # CloudWatch add-on
├── scripts/
│   ├── deploy.sh               # Automated deployment
│   ├── teardown.sh             # Bash teardown
│   └── teardown.ps1            # PowerShell teardown
├── grading.json                # Auto-generated after apply
├── .gitignore
└── README.md
```

---

## 🏷️ Resource Tagging

All resources are tagged with: `Project: karatu-2025-capstone`

This is enforced via:
- Terraform `default_tags` block in the AWS provider
- Explicit `tags` on each resource
- Kubernetes label `Project: karatu-2025-capstone` on K8s resources
- ALB ingress annotation `alb.ingress.kubernetes.io/tags: Project=karatu-2025-capstone`

---

## 📝 License

This project is for educational purposes as part of the Karatu 2025 Capstone.
