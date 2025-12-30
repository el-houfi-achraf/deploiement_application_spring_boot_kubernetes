# ===========================================
# Script PowerShell : Build et Déploiement
# ===========================================
# Ce script automatise tout le processus de build et déploiement

param(
    [switch]$SkipBuild,
    [switch]$UseConfigMap,
    [string]$Namespace = "lab-k8s"
)

$ErrorActionPreference = "Stop"

# Couleurs pour les messages
function Write-Step { param($Message) Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }
function Write-Error { param($Message) Write-Host "[ERREUR] $Message" -ForegroundColor Red }

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  TP33 - Build et Déploiement Kubernetes" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

# Vérification des prérequis
Write-Step "Vérification des prérequis..."

$tools = @("docker", "kubectl", "minikube", "mvn")
foreach ($tool in $tools) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) {
        Write-Success "$tool est disponible"
    } else {
        Write-Error "$tool n'est pas installé ou pas dans le PATH"
        exit 1
    }
}

# Vérification de Minikube
Write-Step "Vérification du cluster Minikube..."
$minikubeStatus = minikube status --format='{{.Host}}' 2>$null
if ($minikubeStatus -ne "Running") {
    Write-Host "Démarrage de Minikube..." -ForegroundColor Yellow
    minikube start
}
Write-Success "Minikube est en cours d'exécution"

# Build du projet Maven
if (-not $SkipBuild) {
    Write-Step "Construction du JAR avec Maven..."
    Push-Location "$PSScriptRoot\..\demo-k8s"
    try {
        mvn clean package -DskipTests -q
        if ($LASTEXITCODE -ne 0) { throw "Erreur Maven" }
        Write-Success "JAR construit avec succès"
    } finally {
        Pop-Location
    }
    
    # Build de l'image Docker
    Write-Step "Construction de l'image Docker..."
    Push-Location "$PSScriptRoot\..\demo-k8s"
    try {
        docker build -t demo-k8s:1.0.0 .
        if ($LASTEXITCODE -ne 0) { throw "Erreur Docker build" }
        Write-Success "Image Docker construite"
    } finally {
        Pop-Location
    }
    
    # Charger l'image dans Minikube
    Write-Step "Chargement de l'image dans Minikube..."
    minikube image load demo-k8s:1.0.0
    Write-Success "Image chargée dans Minikube"
} else {
    Write-Host "Build ignoré (paramètre -SkipBuild)" -ForegroundColor Yellow
}

# Appliquer les manifests Kubernetes
Write-Step "Application des manifests Kubernetes..."
$k8sPath = "$PSScriptRoot\..\k8s"

# Namespace
kubectl apply -f "$k8sPath\namespace.yaml"
Write-Success "Namespace créé"

# ConfigMap (si demandé)
if ($UseConfigMap) {
    kubectl apply -f "$k8sPath\configmap.yaml"
    Write-Success "ConfigMap appliquée"
    
    kubectl apply -f "$k8sPath\deployment-with-configmap.yaml"
    Write-Success "Deployment (avec ConfigMap) appliqué"
} else {
    kubectl apply -f "$k8sPath\deployment.yaml"
    Write-Success "Deployment appliqué"
}

# Service
kubectl apply -f "$k8sPath\service.yaml"
Write-Success "Service appliqué"

# Attente du déploiement
Write-Step "Attente du démarrage des pods..."
kubectl rollout status deployment/demo-k8s-deployment -n $Namespace --timeout=120s

# Affichage des ressources
Write-Step "État des ressources déployées..."
Write-Host "`n--- Pods ---" -ForegroundColor Magenta
kubectl get pods -n $Namespace -o wide

Write-Host "`n--- Services ---" -ForegroundColor Magenta
kubectl get svc -n $Namespace

# URL d'accès
Write-Step "URL d'accès à l'application..."
$minikubeIP = minikube ip
Write-Host "`nApplication accessible à :" -ForegroundColor Green
Write-Host "  http://${minikubeIP}:30080/api/hello" -ForegroundColor White
Write-Host "`nOu utilisez :" -ForegroundColor Green
Write-Host "  minikube service demo-k8s-service -n $Namespace" -ForegroundColor White

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  Déploiement terminé avec succès !" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Yellow
