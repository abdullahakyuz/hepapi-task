pipeline {
    agent any

    environment {
        KUBECONFIG = "C:\\Users\\abdul\\.kube\\config"
    }

    stages {
        stage('Deploy') {
            steps {
                script {
                    // PowerShell betiğini çalıştırma
                    powershell '''
                        # Minikube ve kubectl'in kurulu olduğundan emin olun
                        if (-not (Get-Command minikube -ErrorAction SilentlyContinue)) {
                            Write-Host "Minikube not found. Please install Minikube first."
                            exit 1
                        }

                        if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
                            Write-Host "kubectl not found. Please install kubectl first."
                            exit 1
                        }

                        # Minikube'u başlat
                        Write-Host "Starting Minikube..."
                        minikube start

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
                    '''
                }
            }
        }

        stage('Wait') {
            steps {
                script {
                    // 1 dakika bekleme
                    echo "Waiting for 1 minute before cleanup..."
                    sleep(time: 1, unit: 'MINUTES')
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    // PowerShell betiğini çalıştırma
                    powershell '''
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
                    '''
                }
            }
        }
    }
}
