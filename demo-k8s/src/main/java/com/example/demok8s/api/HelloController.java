package com.example.demok8s.api;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Contrôleur REST exposant l'endpoint /api/hello.
 * 
 * Ce contrôleur démontre :
 * - La lecture de variables d'environnement (pour ConfigMap)
 * - L'affichage d'informations sur le pod (hostname)
 */
@RestController
@RequestMapping("/api")
public class HelloController {

    /**
     * Message configurable via variable d'environnement APP_MESSAGE.
     * Peut être injecté depuis une ConfigMap Kubernetes.
     */
    @Value("${APP_MESSAGE:Hello from Spring Boot on Kubernetes}")
    private String appMessage;

    /**
     * Version de l'application
     */
    @Value("${APP_VERSION:1.0.0}")
    private String appVersion;

    /**
     * Endpoint principal retournant un message JSON.
     * 
     * @return Map contenant le message, le statut, le hostname et le timestamp
     */
    @GetMapping("/hello")
    public Map<String, String> hello() {
        Map<String, String> response = new LinkedHashMap<>();
        response.put("message", appMessage);
        response.put("status", "OK");
        response.put("version", appVersion);
        response.put("hostname", getHostname());
        response.put("timestamp", getCurrentTimestamp());
        return response;
    }

    /**
     * Endpoint de santé simple (complémentaire à Actuator).
     * 
     * @return Map avec le statut de santé
     */
    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new LinkedHashMap<>();
        response.put("status", "UP");
        response.put("service", "demo-k8s");
        return response;
    }

    /**
     * Endpoint d'information sur le pod.
     * 
     * @return Map avec les informations du pod
     */
    @GetMapping("/info")
    public Map<String, Object> info() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("application", "demo-k8s");
        response.put("version", appVersion);
        response.put("hostname", getHostname());
        response.put("javaVersion", System.getProperty("java.version"));
        response.put("osName", System.getProperty("os.name"));
        response.put("timestamp", getCurrentTimestamp());
        
        // Variables d'environnement Kubernetes (si disponibles)
        Map<String, String> k8sInfo = new LinkedHashMap<>();
        k8sInfo.put("podName", System.getenv("HOSTNAME"));
        k8sInfo.put("namespace", System.getenv("POD_NAMESPACE"));
        k8sInfo.put("nodeName", System.getenv("NODE_NAME"));
        response.put("kubernetes", k8sInfo);
        
        return response;
    }

    /**
     * Récupère le hostname (nom du pod dans Kubernetes).
     */
    private String getHostname() {
        try {
            return InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            return "unknown";
        }
    }

    /**
     * Retourne le timestamp actuel formaté.
     */
    private String getCurrentTimestamp() {
        return LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    }
}
