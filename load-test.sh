#!/bin/bash
echo "🚀 Starting load test to generate metrics..."

for i in {1..100}; do
  echo "Request $i"
  curl -s http://4.236.234.155/ > /dev/null
  curl -s http://4.236.234.155/api/data > /dev/null
  
  # Occasionally hit the error endpoint
  if [ $((i % 20)) -eq 0 ]; then
    curl -s http://4.236.234.155/api/error > /dev/null || true
  fi
  
  sleep 2
done

echo "✅ Load test completed! Check your Grafana dashboard: http://4.157.160.63:3000"
