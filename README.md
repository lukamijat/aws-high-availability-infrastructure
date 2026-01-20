
# AWS Resilient Infrastructure with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-%235C4EE5.svg?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=flat&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Project Overview
This project automates the deployment of a **scalable and resilient Web Infrastructure** on Amazon Web Services (AWS) using Terraform. 

The primary goal is to provide an environment that is both **secure** (through private subnetting) and **highly available** (utilizing Multi-AZ deployment and Load Balancing).

---

## Architecture Features



### Network Isolation
* **Private Subnets:** All Webservers run in isolated private subnets with no direct ingress from the public internet.
* **NAT Gateways:** Allow instances in private subnets to connect to the internet for updates while remaining unreachable from outside.

### High Availability & Scalability
* **Multi-AZ Deployment:** Resources are spread across two Availability Zones for redundancy.
* **Elasticity:** Automatic scaling via an **Auto Scaling Group (ASG)** based on CPU load or instance health.
* **Load Balancing:** An **Application Load Balancer (ALB)** serves as the single entry point (Port 80), distributing traffic efficiently.

### Security & Management
* **Least Privilege:** Security Groups are strictly configured to only allow necessary traffic.
* **Dynamic Configuration:** Uses **AWS SSM Parameters** for automatic AMI updates and `user_data` scripts for automated bootstrapping.

---

## Prerequisites

Before deploying, ensure you have the following:

* **Terraform:** v1.0 or higher installed.
* **AWS CLI:** Configured with appropriate administrative privileges.
* **SSH Key:** (Optional) Only required if manual instance access is needed.

---

## Installation Guide

### 1. Clone the Repository
```bash
git clone [https://github.com/lukamijat/aws-high-availability-infrastructure.git](https://github.com/lukamijat/aws-high-availability-infrastructure.git)
cd aws-high-availability-infrastructure

```

### 2. Configure Variables

Review the `variables.tf` file. If you wish to override default values, create a `terraform.tfvars` file:

### 3. Deployment

Run the following commands to provision your infrastructure:

```bash
terraform init
terraform plan
terraform apply

```

> **Note:** Type `yes` when prompted to confirm the deployment.

---
