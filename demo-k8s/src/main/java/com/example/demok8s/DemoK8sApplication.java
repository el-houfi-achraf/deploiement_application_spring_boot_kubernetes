package com.example.demok8s;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Application principale Spring Boot pour démonstration Kubernetes.
 * 
 * Cette application expose une API REST simple qui peut être
 * conteneurisée et déployée sur un cluster Kubernetes.
 */
@SpringBootApplication
public class DemoK8sApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(DemoK8sApplication.class, args);
    }
}
