Write-Host "========================================" -ForegroundColor Red
Write-Host "Project Bedrock - Infrastructure Teardown" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "WARNING: This will destroy ALL resources!" -ForegroundColor Yellow
Write-Host "Press Ctrl+C within 10 seconds to abort..."
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "[1/5] Deleting Kubernetes resources..." -ForegroundColor Cyan
kubectl delete ingress --all -n retail-app --ignore-not-found 2>$null
Write-Host "Waiting 30s for ALB cleanup..."
Start-Sleep -Seconds 30
kubectl delete -f kubernetes/deployments/ --ignore-not-found 2>$null
kubectl delete -f kubernetes/services/ --ignore-not-found 2>$null
kubectl delete -f kubernetes/secrets/ --ignore-not-found 2>$null
kubectl delete -f kubernetes/service-accounts/ --ignore-not-found 2>$null
kubectl delete -f kubernetes/rbac/ --ignore-not-found 2>$null
kubectl delete namespace retail-app --ignore-not-found 2>$null

Write-Host ""
Write-Host "[2/5] Removing Helm releases..." -ForegroundColor Cyan
helm uninstall aws-load-balancer-controller -n kube-system 2>$null
Start-Sleep -Seconds 15

Write-Host ""
Write-Host "[3/5] Emptying S3 buckets..." -ForegroundColor Cyan
aws s3 rm s3://bedrock-assets-alt-soe-025-4486 --recursive 2>$null
 
Write-Host ""
Write-Host "[4/5] Destroying Terraform infrastructure..." -ForegroundColor Cyan
Set-Location terraform
terraform init
terraform destroy -auto-approve

Write-Host ""
Write-Host "[5/5] Removing state bucket..." -ForegroundColor Cyan
aws s3 rm s3://project-bedrock-tfstate-alt-soe-025-4486 --recursive 2>$null
aws s3api delete-bucket --bucket project-bedrock-tfstate-alt-soe-025-4486 --region us-east-1 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Teardown complete! All resources destroyed." -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
