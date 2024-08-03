# PowerShell komutları

# Minikube ve kubectl'in kurulu olduğundan emin olun
if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Host "Minikube not found. Please install Minikube first."
    exit 1
}

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "kubectl not found. Please install kubectl first."
    exit 1
}

# Kubernetes deployment ve servisleri kaldırma
Write-Host "Deleting Kubernetes deployments and services..."

# Deployment ve servisleri silme
kubectl delete -f flask-deploy.yaml
kubectl delete -f mongodb-deploy.yaml

# Silme işleminin tamamlandığını kontrol etme
Write-Host "Waiting for deployments and services to be deleted..."
Start-Sleep -Seconds 10

# Silinen kaynakları kontrol etme
Write-Host "Checking remaining services..."
kubectl get services

Write-Host "Checking remaining deployments..."
kubectl get deployments

Write-Host "Cleanup completed."
