#!/bin/bash

# --- Configuration ---
BASE_URL="http://iot-platform-101.eastus.cloudapp.azure.com:8000"

# --- Test Functions ---

test_root_endpoint() {
  echo "-----------------------------------------------------"
  echo "--- Testing Root Endpoint ---"
  echo "-----------------------------------------------------"

  response=$(curl -s -w "\n%{http_code}" -X GET "${BASE_URL}/" )
  
  http_code=$(echo "$response" | tail -n1)
  body=$(echo "$response" | sed '$d')

  echo "Response Code: ${http_code}, Body: ${body}"

  if [ "$http_code" -eq 200 ] && [ "$(echo "$body" | tr -d '\n')" == '{"message":"Hello World"}' ]; then
    echo "Root endpoint test PASSED"
  else
    echo "Root endpoint test FAILED"
  fi
  echo ""
}

test_endpoint() {
  local endpoint=$1
  local duration=$2
  echo "-----------------------------------------------------"
  echo "--- Testing Endpoint: ${endpoint} for ${duration} seconds ---"
  echo "-----------------------------------------------------"

  # Loop for the specified duration
  for i in $(seq 1 ${duration}); do
    VALUE=$RANDOM
    echo -n "Loop ${i}/${duration}: Sending value ${VALUE}... "
    
    # Send POST request with curl
    response=$(curl -s -w "\n%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"value\": ${VALUE}}" "${BASE_URL}${endpoint}")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    echo "Response Code: ${http_code}, Body: ${body}"
    sleep 1
  done
  echo ""
}

test_grafana_endpoint() {
  echo "-----------------------------------------------------"
  echo "--- Testing Grafana Endpoint ---"
  echo "-----------------------------------------------------"

  response=$(curl -s -w "\n%{http_code}" -X GET "http://iot-platform-101.eastus.cloudapp.azure.com:3000")
  
  http_code=$(echo "$response" | tail -n1)

  echo "Response Code: ${http_code}"

  if [ "$http_code" -eq 200 ] || [ "$http_code" -eq 302 ]; then
    echo "Grafana endpoint test PASSED"
  else
    echo "Grafana endpoint test FAILED"
  fi
  echo ""
}

test_grafana_login() {
  echo "-----------------------------------------------------"
  echo "--- Testing Grafana Login ---"
  echo "-----------------------------------------------------"

  response=$(curl -s -i -X POST -H "Content-Type: application/json" -d '{"user":"itbaiot", "password":"certificacion2025"}' "http://iot-platform-101.eastus.cloudapp.azure.com:3000/login")
  
  http_code=$(echo "$response" | head -n 1 | cut -d ' ' -f 2)
  cookie=$(echo "$response" | grep "grafana_session")

  echo "Response Code: ${http_code}"

  if [ "$http_code" -eq 200 ] && [ -n "$cookie" ]; then
    echo "Grafana login test PASSED"
  else
    echo "Grafana login test FAILED"
  fi
  echo ""
}

# --- Main Execution ---

test_root_endpoint
test_endpoint "/sensors/internal_temp" 5
test_grafana_endpoint
test_grafana_login

echo "-----------------------------------------------------"
echo "--- All tests completed. ---"
echo "-----------------------------------------------------"