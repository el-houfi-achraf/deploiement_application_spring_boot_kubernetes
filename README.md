# TP33 - Déploiement d'une Application Spring Boot sur Kubernetes

## 🎯 Objectifs pédagogiques

À la fin de ce lab, l'étudiant est capable de :

- ✅ Conteneuriser une application Spring Boot avec Docker
- ✅ Créer les manifests Kubernetes de base : Deployment et Service
- ✅ Déployer l'application sur un cluster Kubernetes local (Minikube)
- ✅ Exposer l'API Spring Boot vers l'extérieur du cluster
- ✅ Vérifier le fonctionnement et observer les pods

---

## 📋 Scénario

Une petite API REST Spring Boot expose un endpoint `/api/hello` qui retourne un message JSON.

**Objectif** : déployer cette API sur Kubernetes et l'exposer via un Service de type NodePort.

---

## 🔧 Pré-requis techniques

| Outil | Version recommandée |
|-------|---------------------|
| Java | 17 ou 21 |
| Maven | 3.8+ |
| Docker | 20.10+ |
| Minikube | 1.30+ |
| kubectl | 1.25+ |

> **Note** : Les exemples ci-dessous utilisent Minikube, mais vous pouvez utiliser kind, k3d ou tout autre cluster Kubernetes local.

---

## 📁 Structure du projet

```
TP33/
├── demo-k8s/                          # Projet Spring Boot
│   ├── pom.xml
│   ├── Dockerfile
│   └── src/
│       └── main/
│           ├── java/
│           │   └── com/example/demok8s/
│           │       ├── DemoK8sApplication.java
│           │       └── api/
│           │           └── HelloController.java
│           └── resources/
│               └── application.properties
├── k8s/                               # Manifests Kubernetes
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── scripts/                           # Scripts d'automatisation
│   ├── build-and-deploy.ps1
│   ├── cleanup.ps1
│   └── test-api.ps1
└── README.md
```

---

## 🚀 Étape 1 – Création du projet Spring Boot

### 1.1 Le projet demo-k8s

Le projet Maven est déjà créé dans le dossier `demo-k8s/` avec :
- **Groupe** : `com.example`
- **Artifact** : `demo-k8s`
- **Version** : `0.0.1-SNAPSHOT`

### 1.2 Test local (optionnel)

```powershell
cd demo-k8s
mvn spring-boot:run
```

Dans un autre terminal :
```powershell
curl http://localhost:8080/api/hello
```

Réponse attendue :
```json
{
  "message": "Hello from Spring Boot on Kubernetes",
  "status": "OK"
}
```

---

## 🐳 Étape 2 – Création de l'image Docker

### 2.1 Construction du JAR

```powershell
cd demo-k8s
mvn clean package -DskipTests
```

Le JAR se trouve dans `target/demo-k8s-0.0.1-SNAPSHOT.jar`

### 2.2 Construction de l'image Docker

```powershell
docker build -t demo-k8s:1.0.0 .
```

### 2.3 Test de l'image en local (optionnel)

```powershell
docker run -p 8080:8080 demo-k8s:1.0.0
```

---

## ☸️ Étape 3 – Préparation de Minikube

### 3.1 Démarrage du cluster

```powershell
minikube start
```

### 3.2 Utilisation de l'image Docker locale avec Minikube

#### Option A : Construire dans l'environnement Docker de Minikube (Linux/macOS)
```bash
eval $(minikube docker-env)
docker build -t demo-k8s:1.0.0 .
```

#### Option B : Charger l'image dans Minikube (Windows PowerShell)
```powershell
minikube image load demo-k8s:1.0.0
```

À partir de ce moment, le cluster peut voir l'image `demo-k8s:1.0.0`.

---

## 📦 Étape 4 – Création d'un namespace dédié

### 4.1 Créer le namespace

```powershell
kubectl apply -f k8s/namespace.yaml
```

Ou manuellement :
```powershell
kubectl create namespace lab-k8s
```

### 4.2 Vérification

```powershell
kubectl get namespaces
```

---

## 📝 Étape 5 – Déploiement sur Kubernetes

### 5.1 Appliquer le Deployment

```powershell
kubectl apply -f k8s/deployment.yaml
```

### 5.2 Vérification des pods

```powershell
kubectl get pods -n lab-k8s
kubectl describe deployment demo-k8s-deployment -n lab-k8s
```

---

## 🌐 Étape 6 – Exposition via Service NodePort

### 6.1 Appliquer le Service

```powershell
kubectl apply -f k8s/service.yaml
```

### 6.2 Vérification

```powershell
kubectl get svc -n lab-k8s
```

---

## 🧪 Étape 7 – Test d'accès à l'API

### 7.1 Récupération de l'IP du node Minikube

```powershell
minikube ip
```

### 7.2 Appel de l'API

```powershell
# Remplacer <MINIKUBE_IP> par l'IP retournée
curl http://<MINIKUBE_IP>:30080/api/hello
```

Ou utiliser la commande Minikube :
```powershell
minikube service demo-k8s-service -n lab-k8s --url
```

### 7.3 Réponse attendue

```json
{
  "message": "Hello from Spring Boot on Kubernetes",
  "status": "OK"
}
```

---

## 🔍 Étape 8 – Observation et diagnostic

### 8.1 Liste des pods et services

```powershell
kubectl get pods -n lab-k8s
kubectl get svc -n lab-k8s
kubectl get all -n lab-k8s
```

### 8.2 Logs d'un pod

```powershell
# Récupérer le nom d'un pod
kubectl get pods -n lab-k8s

# Afficher les logs
kubectl logs <POD_NAME> -n lab-k8s
```

### 8.3 Décrire un pod

```powershell
kubectl describe pod <POD_NAME> -n lab-k8s
```

### 8.4 Accès depuis l'intérieur du cluster (optionnel)

```powershell
kubectl run curl-pod -n lab-k8s --image=alpine/curl -it --rm -- sh
# Dans le pod:
curl http://demo-k8s-service:8080/api/hello
```

---

## ⚙️ Étape 9 – Variante avec ConfigMap (optionnel)

### 9.1 Appliquer la ConfigMap

```powershell
kubectl apply -f k8s/configmap.yaml
```

### 9.2 Modifier le Deployment

Le fichier `k8s/deployment-with-configmap.yaml` montre comment référencer la ConfigMap.

### 9.3 Tester

Après redéploiement, le message sera lu depuis la ConfigMap.

---

## 🧹 Étape 10 – Nettoyage du lab

### 10.1 Supprimer les ressources Kubernetes

```powershell
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/configmap.yaml
kubectl delete -f k8s/namespace.yaml
```

Ou utiliser le script :
```powershell
.\scripts\cleanup.ps1
```

### 10.2 Arrêter Minikube

```powershell
minikube stop
```

### 10.3 (Optionnel) Supprimer le cluster

```powershell
minikube delete
```

---

## 🔄 Scripts d'automatisation

### Build et déploiement complet

```powershell
.\scripts\build-and-deploy.ps1
```

### Test de l'API

```powershell
.\scripts\test-api.ps1
```

### Nettoyage

```powershell
.\scripts\cleanup.ps1
```

---

## 📚 Pistes d'extension

1. **Actuator Health Probes** : Ajouter `spring-boot-actuator` et configurer les probes sur `/actuator/health`

2. **Ingress Controller** : Créer un Ingress pour exposer l'application avec un nom de domaine

3. **CI/CD Pipeline** : Intégrer le déploiement dans GitHub Actions ou GitLab CI

4. **Multi-services** : Ajouter un deuxième microservice et tester la communication inter-services

5. **Horizontal Pod Autoscaler** : Configurer l'auto-scaling basé sur les métriques CPU/mémoire

---

## 📖 Commandes utiles

| Commande | Description |
|----------|-------------|
| `kubectl get pods -n lab-k8s` | Lister les pods |
| `kubectl logs <pod> -n lab-k8s` | Voir les logs |
| `kubectl exec -it <pod> -n lab-k8s -- sh` | Shell dans le pod |
| `kubectl port-forward <pod> 8080:8080 -n lab-k8s` | Port forwarding |
| `minikube dashboard` | Interface graphique Kubernetes |
| `minikube service list` | Lister les services exposés |

---

## ❓ Dépannage

### Le pod est en état "ImagePullBackOff"

```powershell
# Vérifier que l'image est chargée dans Minikube
minikube image list | Select-String "demo-k8s"

# Recharger l'image si nécessaire
minikube image load demo-k8s:1.0.0
```

### Le service n'est pas accessible

```powershell
# Vérifier les endpoints
kubectl get endpoints demo-k8s-service -n lab-k8s

# Utiliser minikube service
minikube service demo-k8s-service -n lab-k8s
```

### Les pods ne démarrent pas

```powershell
# Voir les événements
kubectl get events -n lab-k8s --sort-by='.lastTimestamp'

# Décrire le pod pour plus de détails
kubectl describe pod <POD_NAME> -n lab-k8s
```

---

## 🎓 Résumé des concepts

| Concept | Description |
|---------|-------------|
| **Pod** | Plus petite unité déployable dans Kubernetes |
| **Deployment** | Gère le cycle de vie des pods (replicas, rolling updates) |
| **Service** | Expose les pods via une IP stable et un DNS |
| **NodePort** | Type de Service qui expose sur un port du nœud (30000-32767) |
| **ConfigMap** | Stocke la configuration externe aux pods |
| **Namespace** | Isolation logique des ressources |

---

**Bon lab ! 🚀**
