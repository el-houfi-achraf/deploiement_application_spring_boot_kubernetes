# ===========================================
# Dockerfile pour Spring Boot sur Kubernetes
# ===========================================

# Image de base avec JDK 17 (Alpine pour une image légère)
FROM eclipse-temurin:17-jdk-alpine

# Métadonnées de l'image
LABEL maintainer="demo@example.com"
LABEL version="1.0.0"
LABEL description="Demo Spring Boot Application for Kubernetes"

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -S spring && adduser -S spring -G spring

# Définir le répertoire de travail
WORKDIR /app

# Copier le JAR de l'application
COPY target/demo-k8s-0.0.1-SNAPSHOT.jar app.jar

# Changer le propriétaire des fichiers
RUN chown -R spring:spring /app

# Utiliser l'utilisateur non-root
USER spring:spring

# Exposer le port de l'application
EXPOSE 8080

# Variables d'environnement par défaut
ENV JAVA_OPTS=""
ENV APP_MESSAGE="Hello from Spring Boot on Kubernetes"
ENV APP_VERSION="1.0.0"

# Health check Docker (optionnel, Kubernetes utilise ses propres probes)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Point d'entrée avec options JVM optimisées pour les containers
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -jar app.jar"]
