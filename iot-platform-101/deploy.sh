#!/bin/bash

# Script to deploy the IoT platform to the Azure instance

# Variables
USER="savoie"
HOST="iot-platform-101.eastus.cloudapp.azure.com"
PRIVATE_KEY="azure/id_rsa"

echo "Copying project files to the instance..."
rsync -avz -e "ssh -i ${PRIVATE_KEY}" --exclude 'influxdb/data' ./src/ ${USER}@${HOST}:~/src

echo "Starting Docker containers on the instance..."
ssh -i ${PRIVATE_KEY} ${USER}@${HOST} << EOF
    sudo systemctl start docker
    cd src
    sudo docker-compose down
    sudo docker-compose up -d
EOF

echo "Deployment finished."
