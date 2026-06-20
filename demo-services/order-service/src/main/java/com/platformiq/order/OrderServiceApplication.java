package com.platformiq.order;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;

@SpringBootApplication
public class OrderServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(OrderServiceApplication.class, args);
    }
}

@RestController
class OrderController {

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of(
                "service", "order-service",
                "status", "UP",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/ready")
    public Map<String, Object> ready() {
        return Map.of(
                "service", "order-service",
                "status", "READY",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/orders/test")
    public Map<String, Object> testOrder() {
        return Map.of(
                "status", "order created",
                "service", "order-service",
                "timestamp", Instant.now().toString()
        );
    }
}
