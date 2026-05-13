package com.studymate.shared;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Controller que expone un endpoint simple de salud.
 */
@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public HealthResponseDTO health() {
        return new HealthResponseDTO("ok2", "0.1.0");
    }

}
