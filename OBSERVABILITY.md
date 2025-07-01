# 🔍 Observability Stack for Java Application

This document describes the comprehensive observability stack implemented for the Java application running on Azure Kubernetes Service (AKS).

## 📊 Stack Components

### 1. **Prometheus** - Metrics Collection & Alerting
- **URL**: http://51.8.70.66:8080
- **Purpose**: Collects metrics from Java application and Kubernetes cluster
- **Features**:
  - Application metrics (request rate, response time, custom counters)
  - JVM metrics (memory, GC, threads)
  - Kubernetes cluster metrics
  - Alert rules for high error rates and response times

### 2. **Grafana** - Metrics Visualization
- **URL**: http://4.157.160.63:3000
- **Credentials**: admin / admin123
- **Purpose**: Visualizes metrics collected by Prometheus
- **Features**:
  - Pre-configured Java Application Dashboard
  - Real-time monitoring charts
  - Alert visualization
  - Custom dashboard creation

### 3. **ELK Stack** - Centralized Logging

#### Elasticsearch
- **Internal Service**: elasticsearch:9200
- **Purpose**: Stores and indexes application logs
- **Features**:
  - Full-text search capabilities
  - Log aggregation and analysis
  - Scalable storage

#### Logstash
- **Internal Service**: logstash:5044
- **Purpose**: Processes and transforms logs before storing in Elasticsearch
- **Features**:
  - Log parsing and enrichment
  - JSON log processing
  - Kubernetes metadata addition

#### Kibana
- **URL**: http://51.8.14.1:5601
- **Purpose**: Log visualization and analysis
- **Features**:
  - Log search and filtering
  - Dashboard creation
  - Log pattern analysis

### 4. **Jaeger** - Distributed Tracing
- **URL**: http://135.234.240.32:16686
- **Purpose**: Tracks requests across microservices
- **Features**:
  - Request tracing
  - Performance bottleneck identification
  - Service dependency mapping

### 5. **Filebeat** - Log Shipping
- **Purpose**: Collects logs from Kubernetes pods and ships to Logstash
- **Features**:
  - Kubernetes log collection
  - Metadata enrichment
  - Reliable log shipping

## 🚀 Java Application Enhancements

### New Dependencies Added
```gradle
implementation 'org.springframework.boot:spring-boot-starter-actuator'
implementation 'io.micrometer:micrometer-registry-prometheus'
implementation 'io.opentracing.contrib:opentracing-spring-jaeger-web-starter:3.3.1'
implementation 'io.jaegertracing:jaeger-client:1.8.1'
```

### New Endpoints
- `/actuator/health` - Health check with detailed information
- `/actuator/metrics` - Application metrics
- `/actuator/prometheus` - Prometheus-formatted metrics
- `/api/data` - Sample API endpoint with tracing
- `/api/error` - Error simulation for testing alerts

### Metrics Exposed
- `app_requests_total` - Total number of requests
- `home_request_duration` - Response time for home endpoint
- `health_check_duration` - Health check response time
- `api_data_duration` - API data endpoint response time
- JVM metrics (memory, GC, threads)
- HTTP request metrics

## 📈 Monitoring Dashboards

### Grafana Dashboard Features
- **Request Rate**: Real-time requests per second
- **Response Time**: 95th and 50th percentile response times
- **Error Rate**: Application error tracking
- **JVM Metrics**: Memory usage, garbage collection
- **Custom Metrics**: Application-specific counters

### Kibana Log Analysis
- **Log Levels**: INFO, WARN, ERROR, DEBUG
- **Structured Logging**: JSON format with timestamps
- **Kubernetes Context**: Pod, namespace, node information
- **Search Capabilities**: Full-text search across all logs

## 🔔 Alerting Rules

### Prometheus Alerts
1. **High Error Rate**
   - Trigger: Error rate > 10% for 5 minutes
   - Severity: Warning

2. **High Response Time**
   - Trigger: 95th percentile > 500ms for 5 minutes
   - Severity: Warning

## 🛠️ Usage Instructions

### 1. Access Monitoring Tools
```bash
# Get external IPs
kubectl get services -n monitoring

# Check pod status
kubectl get pods -n monitoring
```

### 2. Generate Test Traffic
```bash
# Generate requests to create metrics
for i in {1..100}; do
  curl http://4.236.234.155/
  curl http://4.236.234.155/api/data
  sleep 1
done
```

### 3. View Metrics in Grafana
1. Open http://4.157.160.63:3000
2. Login with admin/admin123
3. Navigate to "Java Application Dashboard"
4. View real-time metrics

### 4. Search Logs in Kibana
1. Open http://51.8.14.1:5601
2. Create index pattern: `java-app-logs-*`
3. Go to Discover tab
4. Search and filter logs

### 5. View Traces in Jaeger
1. Open http://135.234.240.32:16686
2. Select "java-app" service
3. View request traces and performance

## 🔧 Configuration Files

### Application Configuration
- `src/main/resources/application.yml` - Spring Boot configuration
- Actuator endpoints enabled
- Prometheus metrics export enabled
- Jaeger tracing configuration

### Kubernetes Manifests
- `k8s/monitoring/` - All monitoring component deployments
- `k8s/deployment.yaml` - Updated Java app with observability annotations

### Prometheus Configuration
- Service discovery for Kubernetes
- Scraping Java application metrics
- Alert rules for monitoring

## 📊 Key Metrics to Monitor

### Application Metrics
- Request rate (requests/second)
- Response time (percentiles)
- Error rate (%)
- Active connections
- Custom business metrics

### Infrastructure Metrics
- CPU usage
- Memory usage
- Disk I/O
- Network traffic
- Pod restarts

### JVM Metrics
- Heap memory usage
- Garbage collection frequency
- Thread count
- Class loading

## 🚨 Troubleshooting

### Common Issues
1. **Metrics not appearing in Prometheus**
   - Check if Java app pods have prometheus annotations
   - Verify `/actuator/prometheus` endpoint is accessible

2. **Logs not appearing in Kibana**
   - Check Filebeat pods are running on all nodes
   - Verify Logstash is processing logs
   - Check Elasticsearch cluster health

3. **Traces not appearing in Jaeger**
   - Verify Jaeger agent configuration in Java app
   - Check network connectivity to Jaeger service

### Useful Commands
```bash
# Check Java app metrics endpoint
kubectl port-forward svc/java-app-service 8080:80
curl http://localhost:8080/actuator/prometheus

# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus-service 9090:8080
# Open http://localhost:9090/targets

# View application logs
kubectl logs -f deployment/java-app-deployment

# Check monitoring stack health
kubectl get pods -n monitoring
kubectl describe pod <pod-name> -n monitoring
```

## 🎯 Next Steps

1. **Custom Dashboards**: Create application-specific Grafana dashboards
2. **Alert Manager**: Configure AlertManager for notification routing
3. **Log Retention**: Configure log retention policies in Elasticsearch
4. **Performance Tuning**: Optimize resource allocation for monitoring stack
5. **Security**: Implement authentication and authorization for monitoring tools
6. **Backup**: Set up backup strategies for metrics and logs

## 📚 Additional Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Elastic Stack Documentation](https://www.elastic.co/guide/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
