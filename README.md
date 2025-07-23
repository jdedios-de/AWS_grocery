<!-- PROJECT BADGES -->
[![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D1.0.0-blue.svg)](https://www.terraform.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

# AWS Grocery Infra

> Terraform-managed AWS infrastructure for the Grocery App  
> Includes backend API and frontend web app

### [![Watch - Introduction](https://www.youtube.com/watch?v=inNKmnGBUtw)](https://www.youtube.com/watch?v=inNKmnGBUtw)
---

## 📖 Table of Contents

1. [Overview](#%EF%B8%8F-overview)  
2. [Architecture](#-architecture)  
3. [Repository Structure](#-repository-structure)  
4. [Prerequisites](#-prerequisites)  
5. [Getting Started](#-getting-started)
6. [Terraform Configuration](#-terraform-configuration)  
7. [Terraform Workflow](#-terraform-workflow)  
   - [Backend Configuration](#backend-configuration)  
   - [Initializing & Applying](#initializing--applying)  
8. [Backend (API)](#-backend-api)  
9. [Frontend (Web)](#-frontend-web)  
10. [Environment Variables](#-environment-variables)  
11. [Testing](#-testing)  
12. [Deployment](#-deployment)  
13. [Contributing](#-contributing)  
14. [License](#-license)  

---

## ⚙️ Overview

This project is part of the Cloud Track in our Masterschool Software Engineering bootcamp. Originally developed by our Track Mentor, Alejandro Román, my task was to design and deploy its AWS infrastructure step by step.

---

## 🏗 Architecture

![alt text](image-1.png)

![alt text](image.png)

---

## 🔧 Prerequisites
Terraform ≥ 1.0.0

AWS CLI

Docker (for local backend builds)

### [![Watch - Prerequisites](https://www.youtube.com/watch?v=Radpgqt2tQQ)](https://www.youtube.com/watch?v=Radpgqt2tQQ)

---
## 🚀 Getting Started

1. Clone the repository
2. Set up Terraform remote state
3. Configure AWS credentials
4. Set up Docker with ECR

### [![Watch - Getting Started](https://www.youtube.com/watch?v=ALv_n0ZYWls)](https://www.youtube.com/watch?v=ALv_n0ZYWls)

---

## 🚀 Terraform Configuration

```bash
infrastructure
├── scripts
├── environments
│   ├── prod
│   ├── staging
│   └── dev
│       ├── backend.tf
│       ├── terraform.tfvars
│       ├── variables.tf
│       ├── terraform.tfstate.backup
│       ├── terraform.tfstate
│       └── main.tf
├── modules
│   ├── rds
│   │   ├── outputs.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── README.md
│   ├── alb
│   │   ├── outputs.tf
│   │   ├── ec2-security-group.tf
│   │   ├── internet-gateway.tf
│   │   ├── route-table.tf
│   │   ├── listener.tf
│   │   ├── rds-security-group.tf
│   │   ├── alb-security-group.tf
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── README.md
│   ├── vpc
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── public.tf
│   │   ├── private.tf
│   │   ├── main.tf
│   │   └── README.md
│   ├── ecs-cluster
│   │   ├── outputs.tf
│   │   ├── lb-listener.tf
│   │   ├── main.tf
│   │   ├── launch-template.tf
│   │   ├── ecs-service.tf
│   │   ├── auto-scaling-group.tf
│   │   ├── variables.tf
│   │   ├── task-definition.tf
│   │   └── README.md
│   └── s3
│       ├── variables.tf
│       ├── outputs.tf
│       ├── main.tf
│       └── README.md
└── global
    ├── providers.tf
    ├── versions.tf
    ├── backend.tf
    ├── outputs.tf
    ├── variables.tf
    ├── iam.tf
    └── README.md
```
