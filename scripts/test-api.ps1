# ===========================================
# Script PowerShell : Test de l'API
# ===========================================
# Ce script teste les différents endpoints de l'API

param(
    [string]$Namespace = "lab-k8s",
    [switch]$UsePortForward
)

$ErrorActionPreference = "Continue"

function Write-Step { param($Message) Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  TP33 - Test de l'API Kubernetes" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

# Récupérer l'URL
if ($UsePortForward) {
    Write-Step "Démarrage du port-forward..."
    $job = Start-Job -ScriptBlock {
        kubectl port-forward svc/demo-k8s-service 8080:8080 -n $using:Namespace
    }
    Start-Sleep -Seconds 3
    $baseUrl = "http://localhost:8080"
} else {
    $minikubeIP = minikube ip
    $baseUrl = "http://${minikubeIP}:30080"
}

Write-Host "URL de base : $baseUrl" -ForegroundColor White

# Fonction pour tester un endpoint
function Test-Endpoint {
    param(
        [string]$Path,
        [string]$Description
    )
    
    Write-Step "Test : $Description"
    Write-Host "  Endpoint : $Path" -ForegroundColor Gray
    
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl$Path" -Method Get -TimeoutSec 10
        $jsonResponse = $response | ConvertTo-Json -Depth 5
        Write-Host $jsonResponse -ForegroundColor White
        Write-Success "Réponse reçue avec succès"
    } catch {
        Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Tests des endpoints
Test-Endpoint -Path "/api/hello" -Description "Endpoint Hello"
Test-Endpoint -Path "/api/health" -Description "Endpoint Health"
Test-Endpoint -Path "/api/info" -Description "Endpoint Info"
Test-Endpoint -Path "/actuator/health" -Description "Actuator Health"

# Test de load balancing (appels multiples)
Write-Step "Test du Load Balancing (5 appels)..."
Write-Host "  Les hostnames devraient varier entre les replicas`n" -ForegroundColor Gray

for ($i = 1; $i -le 5; $i++) {
    try {
        $response = Invoke-RestMethod -Uri "$baseUrl/api/hello" -Method Get -TimeoutSec 5
        Write-Host "  Appel $i : Hostname = $($response.hostname)" -ForegroundColor White
    } catch {
        Write-Host "  Appel $i : [ERREUR] $($_.Exception.Message)" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 500
}

# Nettoyage du port-forward si utilisé
if ($UsePortForward -and $job) {
    Stop-Job -Job $job
    Remove-Job -Job $job
    Write-Host "`nPort-forward arrêté" -ForegroundColor Yellow
}

# Afficher les pods actuels
Write-Step "État actuel des pods..."
kubectl get pods -n $Namespace -o wide

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  Tests terminés !" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Yellow
