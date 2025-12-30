# ===========================================
# Script PowerShell : Vérification des prérequis
# ===========================================
# Ce script vérifie que tous les outils nécessaires sont installés

$ErrorActionPreference = "Continue"

function Write-Check {
    param(
        [string]$Tool,
        [bool]$Success,
        [string]$Version = ""
    )
    
    if ($Success) {
        $status = "[OK]"
        $color = "Green"
        $message = if ($Version) { "$Tool - Version: $Version" } else { $Tool }
    } else {
        $status = "[MANQUANT]"
        $color = "Red"
        $message = "$Tool - Non trouvé"
    }
    
    Write-Host "$status $message" -ForegroundColor $color
}

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "  TP33 - Vérification des Prérequis" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

$allPassed = $true

# Java
Write-Host "Vérification de Java..." -ForegroundColor Cyan
try {
    $javaVersion = (java -version 2>&1 | Select-Object -First 1) -replace '.*"(.+)".*', '$1'
    Write-Check -Tool "Java" -Success $true -Version $javaVersion
} catch {
    Write-Check -Tool "Java" -Success $false
    $allPassed = $false
}

# Maven
Write-Host "`nVérification de Maven..." -ForegroundColor Cyan
try {
    $mvnVersion = (mvn -version 2>&1 | Select-Object -First 1) -replace 'Apache Maven (.+?) .*', '$1'
    Write-Check -Tool "Maven" -Success $true -Version $mvnVersion
} catch {
    Write-Check -Tool "Maven" -Success $false
    $allPassed = $false
}

# Docker
Write-Host "`nVérification de Docker..." -ForegroundColor Cyan
try {
    $dockerVersion = (docker version --format '{{.Client.Version}}' 2>$null)
    if ($dockerVersion) {
        Write-Check -Tool "Docker" -Success $true -Version $dockerVersion
        
        # Vérifier si Docker Desktop est en cours d'exécution
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Docker Desktop est en cours d'exécution" -ForegroundColor Green
        } else {
            Write-Host "  [ATTENTION] Docker Desktop n'est pas démarré" -ForegroundColor Yellow
        }
    } else {
        throw "Docker non trouvé"
    }
} catch {
    Write-Check -Tool "Docker" -Success $false
    $allPassed = $false
}

# Minikube
Write-Host "`nVérification de Minikube..." -ForegroundColor Cyan
try {
    $minikubeVersion = (minikube version --short 2>$null)
    if ($minikubeVersion) {
        Write-Check -Tool "Minikube" -Success $true -Version $minikubeVersion
        
        # Vérifier le statut
        $minikubeStatus = minikube status --format='{{.Host}}' 2>$null
        if ($minikubeStatus -eq "Running") {
            Write-Host "  Cluster Minikube est en cours d'exécution" -ForegroundColor Green
        } else {
            Write-Host "  [INFO] Cluster Minikube n'est pas démarré (utilisez: minikube start)" -ForegroundColor Yellow
        }
    } else {
        throw "Minikube non trouvé"
    }
} catch {
    Write-Check -Tool "Minikube" -Success $false
    $allPassed = $false
}

# kubectl
Write-Host "`nVérification de kubectl..." -ForegroundColor Cyan
try {
    $kubectlVersion = (kubectl version --client --short 2>$null) -replace 'Client Version: v', ''
    if (-not $kubectlVersion) {
        $kubectlVersion = (kubectl version --client -o json 2>$null | ConvertFrom-Json).clientVersion.gitVersion -replace 'v', ''
    }
    if ($kubectlVersion) {
        Write-Check -Tool "kubectl" -Success $true -Version $kubectlVersion
    } else {
        throw "kubectl non trouvé"
    }
} catch {
    Write-Check -Tool "kubectl" -Success $false
    $allPassed = $false
}

# Résumé
Write-Host "`n========================================" -ForegroundColor Yellow
if ($allPassed) {
    Write-Host "  Tous les prérequis sont satisfaits !" -ForegroundColor Green
    Write-Host "  Vous pouvez commencer le TP." -ForegroundColor Green
} else {
    Write-Host "  Certains prérequis sont manquants." -ForegroundColor Red
    Write-Host "  Veuillez installer les outils manquants." -ForegroundColor Red
}
Write-Host "========================================`n" -ForegroundColor Yellow

# Liens d'installation
if (-not $allPassed) {
    Write-Host "Liens d'installation :" -ForegroundColor Cyan
    Write-Host "  - Java 17 : https://adoptium.net/" -ForegroundColor White
    Write-Host "  - Maven   : https://maven.apache.org/download.cgi" -ForegroundColor White
    Write-Host "  - Docker  : https://www.docker.com/products/docker-desktop/" -ForegroundColor White
    Write-Host "  - Minikube: https://minikube.sigs.k8s.io/docs/start/" -ForegroundColor White
    Write-Host "  - kubectl : https://kubernetes.io/docs/tasks/tools/" -ForegroundColor White
}
