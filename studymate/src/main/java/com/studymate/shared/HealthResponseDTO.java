package com.studymate.shared;

/**
 * DTO de respuesta para el endpoint de salud de la aplicación.
 */
public record HealthResponseDTO(String status, String version) {
}
