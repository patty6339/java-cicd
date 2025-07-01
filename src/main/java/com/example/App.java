package com.example;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import io.micrometer.core.annotation.Timed;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.beans.factory.annotation.Autowired;
import javax.annotation.PostConstruct;
import java.util.Random;
import java.util.List;
import java.util.Optional;

@SpringBootApplication
@RestController
public class App {

    private static final Logger logger = LoggerFactory.getLogger(App.class);
    private Counter requestCounter;
    private Counter userCreationCounter;
    private Random random = new Random();

    @Autowired
    private MeterRegistry meterRegistry;
    
    @Autowired
    private UserRepository userRepository;

    public static void main(String[] args)
    {
        SpringApplication.run(App.class, args);
    }

    @PostConstruct
    public void init()
    {
        logger.info("Java app started with observability features and database integration");
        requestCounter = Counter.builder("app_requests_total")
                .description("Total number of requests")
                .tag("endpoint", "home")
                .register(meterRegistry);
                
        userCreationCounter = Counter.builder("users_created_total")
                .description("Total number of users created")
                .register(meterRegistry);
    }

    @GetMapping("/")
    @Timed(value = "home_request_duration", description = "Time taken to return home page")
    public String home() {
        requestCounter.increment();
        logger.info("Home endpoint accessed");
        
        // Simulate some processing time
        try {
            Thread.sleep(random.nextInt(100));
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        long userCount = userRepository.countAllUsers();
        return "Hello from Java App running on AKS with Observability! Total users: " + userCount;
    }

    @GetMapping("/health")
    @Timed(value = "health_check_duration", description = "Time taken for health check")
    public String health() {
        logger.debug("Health check endpoint accessed");
        return "OK";
    }

    @GetMapping("/api/data")
    @Timed(value = "api_data_duration", description = "Time taken to fetch data")
    public String getData() {
        logger.info("API data endpoint accessed");
        
        // Simulate database call
        try {
            Thread.sleep(random.nextInt(200) + 50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return "{\"message\": \"Sample data from API\", \"timestamp\": " + System.currentTimeMillis() + ", \"users\": " + userRepository.countAllUsers() + "}";
    }

    @GetMapping("/api/users")
    @Timed(value = "users_list_duration", description = "Time taken to list users")
    public List<User> getUsers() {
        logger.info("Users list endpoint accessed");
        return userRepository.findAllOrderByCreatedAtDesc();
    }

    @PostMapping("/api/users")
    @Timed(value = "user_creation_duration", description = "Time taken to create user")
    public User createUser(@RequestBody User user) {
        logger.info("Creating new user: {}", user.getName());
        userCreationCounter.increment();
        
        // Simulate processing time
        try {
            Thread.sleep(random.nextInt(100) + 50);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        return userRepository.save(user);
    }

    @GetMapping("/api/users/{id}")
    @Timed(value = "user_fetch_duration", description = "Time taken to fetch user")
    public User getUser(@PathVariable Long id) {
        logger.info("Fetching user with id: {}", id);
        Optional<User> user = userRepository.findById(id);
        if (user.isPresent()) {
            return user.get();
        } else {
            throw new RuntimeException("User not found with id: " + id);
        }
    }

    @GetMapping("/api/users/search")
    @Timed(value = "user_search_duration", description = "Time taken to search users")
    public List<User> searchUsers(@RequestParam String name) {
        logger.info("Searching users with name: {}", name);
        return userRepository.findByNameContainingIgnoreCase(name);
    }

    @GetMapping("/api/error")
    public String simulateError() {
        logger.error("Simulated error endpoint accessed");
        throw new RuntimeException("This is a simulated error for testing");
    }
}
