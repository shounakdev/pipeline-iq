package com.platformiq.inventory;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@RestController
public class InventoryController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of(
                "service", "inventory-service",
                "status", "UP",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/ready")
    public Map<String, Object> ready() {
        return Map.of(
                "service", "inventory-service",
                "status", "READY",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/inventory/test")
    public Map<String, Object> testInventory() {
        return Map.of(
                "service", "inventory-service",
                "status", "inventory checked",
                "timestamp", Instant.now().toString()
        );
    }
}
