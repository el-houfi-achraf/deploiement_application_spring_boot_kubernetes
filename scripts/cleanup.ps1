# ===========================================
# Script PowerShell : Nettoyage du Lab
# ===========================================
# Ce script supprime toutes les ressources créées pendant le lab

param(
    [string]$Namespace = "lab-k8s",
    [switch]$StopMinikube,
    [switch]$DeleteMinikube,
    [switch]$Force
)

$ErrorActionPreference = "Continue"

function Write-Step { param($Message) Write-Host "`n==> $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "[OK] $Message" -ForegroundColor Green }

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  TP33 - Nettoyage du Lab Kubernetes" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

# Confirmation
if (-not $Force) {
    Write-Host "Cette opération va supprimer :" -ForegroundColor Red
    Write-Host "  - Le namespace '$Namespace' et toutes ses ressources" -ForegroundColor White
    if ($StopMinikube) { Write-Host "  - Arrêter Minikube" -ForegroundColor White }
    if ($DeleteMinikube) { Write-Host "  - Supprimer le cluster Minikube" -ForegroundColor White }
    Write-Host ""
    
    $confirmation = Read-Host "Êtes-vous sûr de vouloir continuer ? (oui/non)"
    if ($confirmation -ne "oui") {
        Write-Host "Opération annulée." -ForegroundColor Yellow
        exit 0
    }
}

# Afficher les ressources avant suppression
Write-Step "Ressources actuelles dans le namespace '$Namespace'..."
kubectl get all -n $Namespace 2>$null

# Suppression des ressources Kubernetes
Write-Step "Suppression des ressources Kubernetes..."
$k8sPath = "$PSScriptRoot\..\k8s"

# Supprimer le service
kubectl delete -f "$k8sPath\service.yaml" --ignore-not-found 2>$null
Write-Success "Service supprimé"

# Supprimer le deployment
kubectl delete -f "$k8sPath\deployment.yaml" --ignore-not-found 2>$null
kubectl delete -f "$k8sPath\deployment-with-configmap.yaml" --ignore-not-found 2>$null
Write-Success "Deployment supprimé"

# Supprimer la ConfigMap
kubectl delete -f "$k8sPath\configmap.yaml" --ignore-not-found 2>$null
Write-Success "ConfigMap supprimée"

# Supprimer le namespace (supprime automatiquement tout ce qu'il contient)
Write-Step "Suppression du namespace..."
kubectl delete namespace $Namespace --ignore-not-found 2>$null
Write-Success "Namespace '$Namespace' supprimé"

# Supprimer l'image Docker de Minikube
Write-Step "Nettoyage de l'image Docker..."
minikube image rm demo-k8s:1.0.0 2>$null
Write-Success "Image Docker supprimée de Minikube"

# Arrêter Minikube si demandé
if ($StopMinikube) {
    Write-Step "Arrêt de Minikube..."
    minikube stop
    Write-Success "Minikube arrêté"
}

# Supprimer le cluster Minikube si demandé
if ($DeleteMinikube) {
    Write-Step "Suppression du cluster Minikube..."
    minikube delete
    Write-Success "Cluster Minikube supprimé"
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  Nettoyage terminé !" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Yellow

# Résumé
Write-Host "Résumé des actions effectuées :" -ForegroundColor Cyan
Write-Host "  [x] Ressources Kubernetes supprimées" -ForegroundColor White
Write-Host "  [x] Namespace '$Namespace' supprimé" -ForegroundColor White
Write-Host "  [x] Image Docker supprimée de Minikube" -ForegroundColor White
if ($StopMinikube) { Write-Host "  [x] Minikube arrêté" -ForegroundColor White }
if ($DeleteMinikube) { Write-Host "  [x] Cluster Minikube supprimé" -ForegroundColor White }
