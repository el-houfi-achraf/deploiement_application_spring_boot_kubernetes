# TP33 - Cheatsheet Kubernetes

## Commandes kubectl Essentielles

### 📦 Gestion des Pods

| Commande | Description |
|----------|-------------|
| `kubectl get pods -n lab-k8s` | Lister les pods |
| `kubectl get pods -n lab-k8s -o wide` | Pods avec infos réseau |
| `kubectl get pods -n lab-k8s -w` | Observer en temps réel |
| `kubectl describe pod <POD> -n lab-k8s` | Détails d'un pod |
| `kubectl logs <POD> -n lab-k8s` | Logs du pod |
| `kubectl logs <POD> -n lab-k8s -f` | Suivre les logs |
| `kubectl logs <POD> -n lab-k8s --previous` | Logs du container précédent |
| `kubectl exec -it <POD> -n lab-k8s -- sh` | Shell dans le pod |
| `kubectl delete pod <POD> -n lab-k8s` | Supprimer un pod |

### 🚀 Gestion des Deployments

| Commande | Description |
|----------|-------------|
| `kubectl get deployments -n lab-k8s` | Lister les deployments |
| `kubectl describe deployment <NAME> -n lab-k8s` | Détails deployment |
| `kubectl scale deployment <NAME> --replicas=3 -n lab-k8s` | Scaler le nombre de pods |
| `kubectl rollout status deployment <NAME> -n lab-k8s` | Statut du rollout |
| `kubectl rollout restart deployment <NAME> -n lab-k8s` | Redémarrer les pods |
| `kubectl rollout undo deployment <NAME> -n lab-k8s` | Rollback |
| `kubectl set image deployment/<NAME> <CONTAINER>=<IMAGE> -n lab-k8s` | Mettre à jour l'image |

### 🌐 Gestion des Services

| Commande | Description |
|----------|-------------|
| `kubectl get svc -n lab-k8s` | Lister les services |
| `kubectl describe svc <NAME> -n lab-k8s` | Détails du service |
| `kubectl get endpoints <NAME> -n lab-k8s` | Voir les endpoints |
| `kubectl port-forward svc/<NAME> 8080:8080 -n lab-k8s` | Port forward |

### ⚙️ Gestion des ConfigMaps

| Commande | Description |
|----------|-------------|
| `kubectl get configmap -n lab-k8s` | Lister les ConfigMaps |
| `kubectl describe configmap <NAME> -n lab-k8s` | Détails |
| `kubectl get configmap <NAME> -n lab-k8s -o yaml` | Voir le contenu YAML |
| `kubectl create configmap <NAME> --from-literal=key=value -n lab-k8s` | Créer depuis littéral |
| `kubectl create configmap <NAME> --from-file=<FILE> -n lab-k8s` | Créer depuis fichier |

### 📁 Gestion des Namespaces

| Commande | Description |
|----------|-------------|
| `kubectl get namespaces` | Lister les namespaces |
| `kubectl create namespace lab-k8s` | Créer un namespace |
| `kubectl delete namespace lab-k8s` | Supprimer (et son contenu) |
| `kubectl config set-context --current --namespace=lab-k8s` | Définir namespace par défaut |

### 🔍 Diagnostic

| Commande | Description |
|----------|-------------|
| `kubectl get all -n lab-k8s` | Toutes les ressources |
| `kubectl get events -n lab-k8s` | Événements |
| `kubectl get events -n lab-k8s --sort-by='.lastTimestamp'` | Événements triés |
| `kubectl top pods -n lab-k8s` | Consommation ressources |
| `kubectl api-resources` | Types de ressources disponibles |

### 📝 Apply/Delete

| Commande | Description |
|----------|-------------|
| `kubectl apply -f <FILE.yaml>` | Appliquer un manifest |
| `kubectl apply -f <DIRECTORY>/` | Appliquer tous les manifests d'un dossier |
| `kubectl delete -f <FILE.yaml>` | Supprimer depuis manifest |
| `kubectl delete -f <FILE.yaml> --ignore-not-found` | Supprimer (ignorer si absent) |

---

## Commandes Minikube Essentielles

| Commande | Description |
|----------|-------------|
| `minikube start` | Démarrer le cluster |
| `minikube stop` | Arrêter le cluster |
| `minikube delete` | Supprimer le cluster |
| `minikube status` | Statut du cluster |
| `minikube ip` | IP du nœud |
| `minikube dashboard` | Ouvrir le dashboard web |
| `minikube service <NAME> -n lab-k8s` | Ouvrir un service dans le navigateur |
| `minikube service <NAME> -n lab-k8s --url` | Afficher l'URL du service |
| `minikube tunnel` | Créer un tunnel pour LoadBalancer |
| `minikube image load <IMAGE>` | Charger une image Docker |
| `minikube image list` | Lister les images |
| `minikube ssh` | SSH dans le nœud |
| `minikube logs` | Logs Minikube |

---

## Commandes Docker Essentielles

| Commande | Description |
|----------|-------------|
| `docker build -t <NAME>:<TAG> .` | Construire une image |
| `docker images` | Lister les images |
| `docker run -p 8080:8080 <IMAGE>` | Exécuter un container |
| `docker ps` | Containers en cours |
| `docker logs <CONTAINER>` | Logs d'un container |
| `docker stop <CONTAINER>` | Arrêter un container |
| `docker rm <CONTAINER>` | Supprimer un container |
| `docker rmi <IMAGE>` | Supprimer une image |

---

## Commandes Maven Essentielles

| Commande | Description |
|----------|-------------|
| `mvn clean` | Nettoyer le projet |
| `mvn compile` | Compiler |
| `mvn package` | Créer le JAR |
| `mvn package -DskipTests` | JAR sans tests |
| `mvn spring-boot:run` | Lancer l'application |
| `mvn test` | Exécuter les tests |

---

## Structure YAML Kubernetes

### Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: <NAME>
  namespace: <NAMESPACE>
spec:
  replicas: <N>
  selector:
    matchLabels:
      app: <LABEL>
  template:
    metadata:
      labels:
        app: <LABEL>
    spec:
      containers:
        - name: <CONTAINER_NAME>
          image: <IMAGE>:<TAG>
          ports:
            - containerPort: <PORT>
```

### Service NodePort
```yaml
apiVersion: v1
kind: Service
metadata:
  name: <NAME>
  namespace: <NAMESPACE>
spec:
  type: NodePort
  selector:
    app: <LABEL>
  ports:
    - port: <SERVICE_PORT>
      targetPort: <CONTAINER_PORT>
      nodePort: <NODE_PORT>  # 30000-32767
```

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: <NAME>
  namespace: <NAMESPACE>
data:
  key1: "value1"
  key2: "value2"
```
