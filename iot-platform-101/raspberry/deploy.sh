#!/bin/bash

# Script to deploy the IoT platform to the Raspberry Pi

# Variables
USER="ramiro"
HOST="raspberrypi16n"

echo "Copying project files to the instance..."
rsync -avz --exclude 'influxdb/data' ./src/ ${USER}@${HOST}:~/src

echo "Starting Docker containers on the instance..."
ssh ${USER}@${HOST} << EOF
    cd src
    docker compose down
    docker compose up
EOF

echo "Deployment finished."