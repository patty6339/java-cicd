# Multi-stage build
# Stage 1: Build the application
FROM openjdk:8-jdk-alpine AS builder

WORKDIR /app
COPY . .

# Make gradlew executable and build the application
RUN chmod +x ./gradlew && ./gradlew build --no-daemon

# Stage 2: Create the runtime image
FROM openjdk:8-jre-alpine

EXPOSE 8080

# Copy the built JAR from the builder stage (Spring Boot creates a different name)
COPY --from=builder /app/build/libs/*.jar /usr/app/app.jar
WORKDIR /usr/app

ENTRYPOINT ["java", "-jar", "app.jar"]
