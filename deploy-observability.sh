#!/bin/bash

echo "🚀 Deploying Observability Stack for Java App"

# Create namespace and RBAC
echo "📋 Creating namespace and RBAC..."
kubectl apply -f k8s/monitoring/rbac.yaml

# Wait for namespace to be ready
kubectl wait --for=condition=Ready namespace/monitoring --timeout=60s

# Deploy Elasticsearch
echo "🔍 Deploying Elasticsearch..."
kubectl apply -f k8s/monitoring/elasticsearch-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/elasticsearch -n monitoring

# Deploy Logstash
echo "📊 Deploying Logstash..."
kubectl apply -f k8s/monitoring/logstash-config.yaml
kubectl wait --for=condition=available --timeout=300s deployment/logstash -n monitoring

# Deploy Kibana
echo "📈 Deploying Kibana..."
kubectl apply -f k8s/monitoring/kibana-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/kibana -n monitoring

# Deploy Prometheus
echo "📊 Deploying Prometheus..."
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

# Deploy Grafana
echo "📊 Deploying Grafana..."
kubectl apply -f k8s/monitoring/grafana-config.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring

# Deploy Jaeger
echo "🔍 Deploying Jaeger..."
kubectl apply -f k8s/monitoring/jaeger-deployment.yaml
kubectl wait --for=condition=available --timeout=300s deployment/jaeger -n monitoring

# Deploy Filebeat
echo "📋 Deploying Filebeat..."
kubectl apply -f k8s/monitoring/filebeat-config.yaml

echo "✅ Observability stack deployment completed!"

echo ""
echo "🌐 Service URLs (once LoadBalancers are ready):"
echo "Grafana: http://<GRAFANA_EXTERNAL_IP>:3000 (admin/admin123)"
echo "Prometheus: http://<PROMETHEUS_EXTERNAL_IP>:8080"
echo "Kibana: http://<KIBANA_EXTERNAL_IP>:5601"
echo "Jaeger: http://<JAEGER_EXTERNAL_IP>:16686"

echo ""
echo "📊 To get external IPs, run:"
echo "kubectl get services -n monitoring"

echo ""
echo "🔄 To check deployment status:"
echo "kubectl get pods -n monitoring"
