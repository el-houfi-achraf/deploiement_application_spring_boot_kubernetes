# TP33 - Déploiement Spring Boot sur Kubernetes

## Dépannage et Solutions aux Problèmes Courants

---

### 🔴 Problème : ImagePullBackOff ou ErrImagePull

**Symptôme :**
```
kubectl get pods -n lab-k8s
NAME                                   READY   STATUS             RESTARTS   AGE
demo-k8s-deployment-xxx                0/1     ImagePullBackOff   0          2m
```

**Cause :** Kubernetes ne trouve pas l'image Docker `demo-k8s:1.0.0`

**Solutions :**

1. **Vérifier que l'image est chargée dans Minikube :**
   ```powershell
   minikube image list | Select-String "demo-k8s"
   ```

2. **Recharger l'image :**
   ```powershell
   docker build -t demo-k8s:1.0.0 ./demo-k8s
   minikube image load demo-k8s:1.0.0
   ```

3. **Vérifier que `imagePullPolicy` est `IfNotPresent` :**
   ```yaml
   imagePullPolicy: IfNotPresent
   ```

---

### 🔴 Problème : CrashLoopBackOff

**Symptôme :**
```
NAME                                   READY   STATUS             RESTARTS   AGE
demo-k8s-deployment-xxx                0/1     CrashLoopBackOff   5          5m
```

**Cause :** L'application plante au démarrage

**Solutions :**

1. **Consulter les logs :**
   ```powershell
   kubectl logs <POD_NAME> -n lab-k8s
   kubectl logs <POD_NAME> -n lab-k8s --previous
   ```

2. **Décrire le pod :**
   ```powershell
   kubectl describe pod <POD_NAME> -n lab-k8s
   ```

3. **Vérifier les ressources mémoire :**
   - Augmenter les limites si nécessaire dans `deployment.yaml`

---

### 🔴 Problème : Le service n'est pas accessible

**Symptôme :**
```
curl: (7) Failed to connect to 192.168.49.2 port 30080
```

**Solutions :**

1. **Vérifier que les pods sont Ready :**
   ```powershell
   kubectl get pods -n lab-k8s
   ```

2. **Vérifier les endpoints du service :**
   ```powershell
   kubectl get endpoints demo-k8s-service -n lab-k8s
   ```
   - Si vide, le selector ne correspond pas aux labels des pods

3. **Utiliser minikube service :**
   ```powershell
   minikube service demo-k8s-service -n lab-k8s
   ```

4. **Tunnel Minikube (Windows) :**
   ```powershell
   minikube tunnel
   ```

---

### 🔴 Problème : Les Readiness/Liveness probes échouent

**Symptôme :**
```
Readiness probe failed: Get "http://10.244.0.x:8080/actuator/health": dial tcp: connection refused
```

**Solutions :**

1. **Augmenter `initialDelaySeconds` :**
   ```yaml
   readinessProbe:
     initialDelaySeconds: 30  # Plus de temps pour démarrer
   ```

2. **Vérifier que Actuator est configuré :**
   - Dépendance dans `pom.xml`
   - Configuration dans `application.properties`

3. **Tester manuellement dans le pod :**
   ```powershell
   kubectl exec -it <POD_NAME> -n lab-k8s -- wget -q -O- http://localhost:8080/actuator/health
   ```

---

### 🔴 Problème : Minikube ne démarre pas

**Solutions :**

1. **Supprimer et recréer le cluster :**
   ```powershell
   minikube delete
   minikube start
   ```

2. **Vérifier Docker Desktop :**
   - S'assurer que Docker Desktop est démarré
   - Vérifier les ressources allouées (RAM, CPU)

3. **Utiliser un driver différent :**
   ```powershell
   minikube start --driver=hyperv
   # ou
   minikube start --driver=docker
   ```

---

### 🔴 Problème : ConfigMap non prise en compte

**Solutions :**

1. **Vérifier que la ConfigMap existe :**
   ```powershell
   kubectl get configmap demo-k8s-config -n lab-k8s -o yaml
   ```

2. **Redémarrer les pods après modification :**
   ```powershell
   kubectl rollout restart deployment demo-k8s-deployment -n lab-k8s
   ```

3. **Vérifier les variables d'environnement dans le pod :**
   ```powershell
   kubectl exec -it <POD_NAME> -n lab-k8s -- printenv | grep APP_
   ```

---

### 🔴 Problème : Namespace "lab-k8s" n'existe pas

**Solution :**
```powershell
kubectl create namespace lab-k8s
# ou
kubectl apply -f k8s/namespace.yaml
```

---

### 🔧 Commandes de Diagnostic Utiles

```powershell
# Lister tous les événements du namespace
kubectl get events -n lab-k8s --sort-by='.lastTimestamp'

# Voir la configuration complète d'un pod
kubectl get pod <POD_NAME> -n lab-k8s -o yaml

# Exécuter un shell dans un pod
kubectl exec -it <POD_NAME> -n lab-k8s -- sh

# Port-forward pour test direct
kubectl port-forward <POD_NAME> 8080:8080 -n lab-k8s

# Dashboard Kubernetes
minikube dashboard

# Voir les ressources consommées
kubectl top pods -n lab-k8s
```

---

### 📝 Checklist de Dépannage

1. ☐ Minikube est démarré (`minikube status`)
2. ☐ Docker Desktop fonctionne (`docker info`)
3. ☐ L'image est construite (`docker images | grep demo-k8s`)
4. ☐ L'image est dans Minikube (`minikube image list`)
5. ☐ Le namespace existe (`kubectl get ns lab-k8s`)
6. ☐ Les pods sont Running (`kubectl get pods -n lab-k8s`)
7. ☐ Les endpoints sont configurés (`kubectl get endpoints -n lab-k8s`)
8. ☐ Le service est créé (`kubectl get svc -n lab-k8s`)
