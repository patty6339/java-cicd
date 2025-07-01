# Root Cause Analysis: Java App Deployment Rollout Failure

## Issue Summary
The `java-app-deployment` rollout was stuck with the error:
```
Waiting for deployment "java-app-deployment" rollout to finish: 1 out of 3 new replicas have been updated...
Error: deployment "java-app-deployment" exceeded its progress deadline
```

## Root Causes Identified

### 1. Insufficient CPU Resources in Cluster
- **Problem**: Both PostgreSQL and Java application pods were stuck in `Pending` status
- **Details**: 
  - Cluster had 5 nodes with insufficient CPU capacity
  - Each pod required 250m CPU but cluster couldn't accommodate new pods
  - Cluster autoscaler had reached maximum node group size
- **Evidence**: 
  ```
  0/5 nodes are available: 5 Insufficient cpu. preemption: 0/5 nodes are available: 5 No preemption victims found for incoming pod.
  pod didn't trigger scale-up: 1 max node group size reached
  ```

### 2. PostgreSQL Database Unavailability
- **Problem**: PostgreSQL pod was stuck in `Pending` status for 166+ minutes
- **Impact**: Java application couldn't establish database connections
- **Dependency Chain**: Java App → PostgreSQL Service → PostgreSQL Pod (Pending)

### 3. Database Credential Mismatch
- **Problem**: Java application configuration didn't match PostgreSQL deployment settings
- **Mismatch Details**:
  
  | Component | Username | Password | Database |
  |-----------|----------|----------|----------|
  | PostgreSQL Config | `javaapp` | `password123` | `javaappdb` |
  | Java App Config | `postgres` ❌ | `password` ❌ | `javaappdb` ✅ |

- **Error**: `FATAL: password authentication failed for user "postgres"`

## Timeline of Events

1. **Initial State**: 3 running pods from old ReplicaSet
2. **Rollout Started**: New ReplicaSet created with 1 pod
3. **Resource Constraint**: New pod stuck in `Pending` due to CPU shortage
4. **PostgreSQL Issue**: Database pod also pending due to same resource constraints
5. **Application Crashes**: When resources freed up, app crashed due to credential mismatch
6. **Progress Deadline**: Deployment exceeded 600s timeout

## Resolution Steps Applied

### Step 1: Resource Optimization
```bash
# Reduced PostgreSQL CPU requirements
kubectl patch deployment postgres --patch '{"spec":{"template":{"spec":{"containers":[{"name":"postgres","resources":{"requests":{"cpu":"100m","memory":"256Mi"},"limits":{"cpu":"500m","memory":"512Mi"}}}]}}}}'

# Reduced Java App CPU requirements  
kubectl patch deployment java-app-deployment --patch '{"spec":{"template":{"spec":{"containers":[{"name":"java-app","resources":{"requests":{"cpu":"100m","memory":"256Mi"},"limits":{"cpu":"500m","memory":"512Mi"}}}]}}}}'
```

### Step 2: Database Credential Fix
```bash
# Updated Java app with correct database credentials
kubectl patch deployment java-app-deployment --patch '{"spec":{"template":{"spec":{"containers":[{"name":"java-app","env":[{"name":"SPRING_PROFILES_ACTIVE","value":"prod"},{"name":"SPRING_DATASOURCE_URL","value":"jdbc:postgresql://postgres-service:5432/javaappdb"},{"name":"SPRING_DATASOURCE_USERNAME","value":"javaapp"},{"name":"SPRING_DATASOURCE_PASSWORD","value":"password123"},{"name":"JAEGER_AGENT_HOST","value":"jaeger-service.monitoring.svc.cluster.local"},{"name":"JAEGER_AGENT_PORT","value":"6831"}]}]}}}}'
```

## Final Status
- ✅ PostgreSQL: 1/1 pods running
- ✅ Java App: 3/3 pods running and ready
- ✅ Deployment rollout: Successfully completed
- ✅ All health checks passing

## Lessons Learned & Recommendations

### 1. Resource Planning
- Monitor cluster resource utilization before deployments
- Use `kubectl top nodes` and `kubectl top pods` regularly
- Plan for resource headroom during rolling updates
- Consider cluster autoscaler limits and scaling policies

### 2. Dependency Management
- Ensure dependent services (databases) are healthy before app deployments
- Implement proper startup dependencies and health checks
- Use init containers for database readiness checks

### 3. Configuration Management
- Use consistent credential management across all components
- Leverage Kubernetes secrets for sensitive data
- Implement configuration validation in CI/CD pipelines
- Document environment variable mappings

### 4. Monitoring & Alerting
- Set up alerts for pod scheduling failures
- Monitor deployment progress deadlines
- Implement comprehensive logging for troubleshooting
- Use readiness/liveness probes effectively

### 5. Deployment Strategy
- Consider resource requirements during rolling updates
- Implement proper rollback strategies
- Test deployments in staging environments with similar resource constraints
- Use deployment strategies like blue-green for critical applications

## Prevention Measures

1. **Pre-deployment Checks**:
   - Validate cluster resource availability
   - Verify dependent service health
   - Confirm configuration consistency

2. **Automated Testing**:
   - Include resource constraint testing in CI/CD
   - Validate database connectivity in integration tests
   - Test credential configurations

3. **Monitoring Setup**:
   - Resource utilization dashboards
   - Deployment status monitoring
   - Application health metrics

## Related Files
- Deployment manifests: `/k8/`
- Application configuration: Environment variables in deployment
- Database secrets: `postgres-secret` in default namespace
