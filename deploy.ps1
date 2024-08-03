# Minikube ve kubectl'in kurulu olduğundan emin olun
if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
    Write-Host "Minikube not found. Please install Minikube first."
    exit 1
}

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "kubectl not found. Please install kubectl first."
    exit 1
}

# YAML dosyalarını uygulama
Write-Host "Applying Kubernetes manifests..."
kubectl apply -f flask-deploy.yaml
kubectl apply -f mongodb-deploy.yaml

# Pod'ların ve servislerin durumunu kontrol etme
Write-Host "Waiting for pods to be ready..."
kubectl rollout status deployment/flask-app
kubectl rollout status deployment/mongodb

Write-Host "Checking services..."
kubectl get services

# Minikube servis URL'sini geçici bir dosyaya al
Write-Host "Getting service URL..."
$SERVICE_URL_FILE = [System.IO.Path]::GetTempFileName()
minikube service flask-app --url | Out-File -FilePath $SERVICE_URL_FILE -Encoding utf8

if (-not (Test-Path $SERVICE_URL_FILE) -or (Get-Content $SERVICE_URL_FILE).Trim() -eq "") {
    Write-Host "Failed to get service URL. Ensure Minikube tunnel is running."
    Remove-Item $SERVICE_URL_FILE
    exit 1
}

$SERVICE_URL = Get-Content $SERVICE_URL_FILE
Remove-Item $SERVICE_URL_FILE

Write-Host "Flask app is available at: $SERVICE_URL"

# Tarayıcıda URL'yi açma
Write-Host "Opening the application in your default web browser..."
Start-Process $SERVICE_URL

# SERVICE URL'yi ekranda çıktı olarak yaz
Write-Host "The Flask app is accessible at the following URL: $SERVICE_URL"
