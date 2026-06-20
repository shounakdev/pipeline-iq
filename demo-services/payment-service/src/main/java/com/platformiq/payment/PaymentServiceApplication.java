package com.platformiq.payment;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.Map;
import java.util.Random;

@SpringBootApplication
public class PaymentServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(PaymentServiceApplication.class, args);
    }
}

@RestController
class PaymentController {

    private final Random random = new Random();

    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of(
                "service", "payment-service",
                "status", "UP",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/ready")
    public Map<String, Object> ready() {
        return Map.of(
                "service", "payment-service",
                "status", "READY",
                "timestamp", Instant.now().toString()
        );
    }

    @GetMapping("/payments/test")
    public ResponseEntity<Map<String, Object>> testPayment() {
        if (isEnabled("SIMULATE_HIGH_LATENCY")) {
            sleep(3000);
        }

        if (isEnabled("SIMULATE_DATABASE_TIMEOUT")) {
            sleep(5000);
            return ResponseEntity.status(HttpStatus.GATEWAY_TIMEOUT).body(Map.of(
                    "status", "database timeout",
                    "service", "payment-service",
                    "error", "Simulated database timeout"
            ));
        }

        if (isEnabled("SIMULATE_PAYMENT_FAILURE")) {
            return ResponseEntity.status(HttpStatus.PAYMENT_REQUIRED).body(Map.of(
                    "status", "payment failed",
                    "service", "payment-service",
                    "error", "Simulated payment failure"
            ));
        }

        if (isEnabled("SIMULATE_RANDOM_500") && random.nextInt(100) < 30) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of(
                    "status", "internal server error",
                    "service", "payment-service",
                    "error", "Simulated random 500 error"
            ));
        }

        return ResponseEntity.ok(Map.of(
                "status", "payment processed",
                "service", "payment-service",
                "timestamp", Instant.now().toString()
        ));
    }

    private boolean isEnabled(String key) {
        return "true".equalsIgnoreCase(System.getenv().getOrDefault(key, "false"));
    }

    private void sleep(long millis) {
        try {
            Thread.sleep(millis);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
        }
    }
}
