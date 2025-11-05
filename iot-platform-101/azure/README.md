# Azure Infrastructure Deployment

This document describes how to deploy the infrastructure on Azure and how to run the application.

## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deployment

1. **Login to Azure**
   ```bash
   az login
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Apply Terraform configuration**
   ```bash
   terraform apply
   ```
   This will create the following resources:
   - Resource Group
   - Virtual Network
   - Subnet
   - Public IP
   - Network Security Group
   - Network Interface
   - Virtual Machine

4. **Get the public IP address**
   After the deployment is complete, you can get the public IP address of the virtual machine by running the following command:
   ```bash
   terraform output instance_ip
   ```

## Application

1. **Clone the repository**
   Connect to the virtual machine using SSH:
   ```bash
   ssh savoie@<public_ip>
   ```
   Then clone the repository:
   ```bash
   git clone https://github.com/savoie/iot-platform-101.git
   ```

2. **Run the application**
   Navigate to the `src` directory and run the application using docker-compose:
   ```bash
   cd iot-platform-101/src
   docker-compose up -d
   ```

3. **Access Grafana**
   You can access Grafana by opening the following URL in your browser:
   ```
   http://<public_ip>:3000
   ```