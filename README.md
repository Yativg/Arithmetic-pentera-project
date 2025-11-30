# Arithmetic Server Application - DevOps Assignment Submission

This repository contains a complete implementation of the DevOps home assignment, featuring a Python client-server arithmetic application with full CI/CD automation and AWS infrastructure deployment.

---

## 📋 Deliverables Overview

### 1. ✅ Arithmetic Python Server Application

**Location:** `src/` directory

- **Server** (`src/server.py`) - Receives arithmetic operations, processes them, returns results
- **Client** (`src/client.py`) - Interactive CLI for user input and communication with server
- **Operations** (`src/operations.py`) - **BONUS**: Abstract base class with concrete implementations (AddOperation, SubtractOperation, MultiplyOperation, DivideOperation)

**Features:**
- TCP socket communication with JSON protocol
- Comprehensive logging to console for every operation
- Support for four operations: `+`, `-`, `*`, `/`
- Error handling for invalid inputs and division by zero

### 2. ✅ Dockerfile

**Location:** `Dockerfile` (root directory)

- Multi-stage build for optimal layer caching (**BONUS**)
- Minimal image size using `python:3.11-slim` base (**BONUS**)
- Non-root user for security
- Health checks included
- **Fully commented** explaining each step

**Docker Hub:** `docker.io/yativg/arithmetic-server`
- Registry: Docker Hub (docker.io)
- Repository: `yativg/arithmetic-server`
- Tags: `latest` and build number (e.g., `1`, `2`, `3`...)

### 3. ✅ Jenkins Installation & CI/CD Pipeline

**Live Jenkins Server:** http://100.26.89.28:8080/

**Pipeline Job:** http://100.26.89.28:8080/job/arithmetic-server-pipeline/

#### Deployment Details

The Jenkins server was deployed to AWS using **Terraform** (**BONUS requirement**):

- **Infrastructure as Code:** `infrastructure/terraform/`
- **Deployment Configuration:** 
  - Region: `us-east-1`
  - Instance Type: `t3.micro`
  - VPC CIDR: `10.0.0.0/16`
  - Project Name: `pentera-jenkins`
  - Environment: `dev`

**Terraform Files:**
- `main.tf` - Main infrastructure configuration (VPC, Security Groups, EC2, Elastic IP)
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values (Jenkins URL, IP address)
- `terraform.tfvars` - Actual configuration values used for deployment
- `user_data.sh` - EC2 initialization script for Jenkins installation

### 4. ✅ Build Automation (Groovy Scripts)

**Location:** `Jenkinsfile` (root directory)

The Jenkins pipeline includes **comprehensive error handling** (**BONUS requirement**) with try-catch blocks at every stage.

#### Pipeline Stages

**Stage 1: Preparation**
- Cleans workspace
- Checks out source code from Git
- Verifies all required files exist (`Dockerfile`, `src/server.py`, `src/client.py`, `src/operations.py`)
- **Error Handling:** Fails fast if any required files are missing

**Stage 2: Build Docker Image**
- Builds Docker image with proper tagging
- Tags with both build number and `latest` tag
- Includes build metadata (date, VCS ref, build number)
- Displays image size and details
- **Error Handling:** Catches and logs build failures

**Stage 3: Test Docker Image**
- Stops any existing containers on port 5555
- Runs container in test mode
- Verifies container is running
- Executes connectivity test from inside container
- Tests arithmetic operation (10 + 5 = 15)
- **Error Handling:** Automatic cleanup of test containers in `finally` block

**Stage 4: Push to Registry**
- Logs into Docker Hub using Jenkins credentials
- Pushes to: `docker.io/yativg/arithmetic-server`
- Pushes both versioned tag (build number) and `latest` tag
- **Error Handling:** Automatic logout in `finally` block

**Stage 5: Deploy Locally**
- Stops existing deployment if present
- Deploys new container with restart policy
- Verifies deployment success
- **Error Handling:** Catches deployment failures

**Stage 6: Verify Application**
- Runs comprehensive functional tests
- Tests multiple arithmetic operations:
  - Addition: `10 + 5 = 15`
  - Subtraction: `20 - 8 = 12`
  - Multiplication: `6 * 7 = 42`
  - Division: `100 / 4 = 25.0`
  - Edge cases: division results, zero operations
- Verifies correct responses from server
- **Error Handling:** Detailed error reporting for each test

**Post-Build Actions:**
- Success: Logs successful completion
- Failure: Logs failure with build details
- Always: Cleans up old Docker images and workspace

### 5. ✅ Deployment and Verification

**Deployment Options Provided:**

1. **Local Python** - Direct execution for development
2. **Docker Container** - Single container deployment
3. **Docker Compose** - Orchestrated deployment with health checks
4. **Jenkins Pipeline** - Automated CI/CD deployment
5. **AWS Infrastructure** - Production-ready cloud deployment

**Verification:**
- Automated tests in Jenkins pipeline
- Manual testing script: `scripts/quick-test.sh`
- Health checks in Docker containers
- Comprehensive logging for debugging

### 6. ✅ Documentation

**Location:** This `README.md` file

**What's Documented:**
- Complete overview of the submission
- Live Jenkins server URL and pipeline details
- Infrastructure deployment details (Terraform)
- How to review and test the application
- All requirements and bonus features explained

**Code Comments:**
- ✅ Dockerfile fully commented
- ✅ Jenkinsfile extensively commented
- ✅ Python source code documented with docstrings
- ✅ Terraform files commented

---

## 🏗️ Architecture Overview

### Application Architecture

```
┌─────────────┐         TCP/JSON          ┌─────────────┐
│   Client    │ ───────────────────────> │   Server    │
│  (src/      │  {num1, num2, operation} │  (src/      │
│  client.py) │ <─────────────────────── │  server.py) │
└─────────────┘   {status, result}       └─────────────┘
                                                │
                                                │ uses
                                                ▼
                                        ┌──────────────┐
                                        │ Operations   │
                                        │ (Abstract    │
                                        │  Classes)    │
                                        └──────────────┘
```

### CI/CD Pipeline Flow

```
Git Push → Jenkins → Build → Test → Push to Registry → Deploy → Verify
```

### Infrastructure Architecture

```
AWS VPC (10.0.0.0/16)
├── Internet Gateway
├── Public Subnet (10.0.1.0/24)
│   └── EC2 Instance (t3.micro)
│       ├── Jenkins (port 8080)
│       ├── Arithmetic Server (port 5555)
│       └── SSH (port 22)
└── Elastic IP (100.26.89.28)
```
