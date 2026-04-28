# Hardened CI/CD Pipeline: Python FastAPI to AWS EC2 via Terraform & Docker

# Part 1: Continuous Integration (CI) & Hardening

![CI/CD Pipeline](https://img.shields.io/github/actions/workflow/status/2Kelvin/automated-deployment-pipeline/full-cicd.yaml?label=CI/CD%20Pipeline&style=for-the-badge)
![Trivy Scan](https://img.shields.io/badge/Security-Trivy_Checked-blue?style=for-the-badge)
![Docker Size](https://img.shields.io/badge/Docker_Image_Size-173MB-green?style=for-the-badge)

## 📌 Continuous Integration (CI) Overview

This part 1 demonstrates a production-grade Continuous Integration (CI) pipeline for a containerized Python FastAPI application. It bridges the gap between "code that works" and "code that is ready for the enterprise" by implementing automated quality gates, multi-stage builds and advanced security hardening.

## 🛠 Tech Stack

- **API Framework:** FastAPI (Python 3.13)
- **Database:** PostgreSQL
- **Containerization:** Docker & Docker Compose
- **CI/CD:** GitHub Actions
- **Security:** Trivy (Vulnerability Scanning) & Ruff (Linting)
- **Quality:** Pytest & Multi-stage builds

## 🚀 Key CI Engineering Features

### 1. Automated Quality Gates

Every `Pull Request` triggers a sequential safety net:

- **Linting:** Uses `Ruff` to enforce PEP 8 standards.
- **Unit Testing:** Automated testing via `Pytest` ensures logic integrity before any build starts.
- **Dependency Isolation:** Separate jobs for linting and testing ensure fast feedback loops.

### 2. Security Hardening & Container Minification

- **Vulnerability Scanning:** Integrated `Trivy` scan that fails the build if `HIGH` or `CRITICAL` vulnerabilities are found.
- **Non-Root Execution:** The application runs under a dedicated user rather than `root`, mitigating potential container breakout risks.
- **Package Upgrades:** Explicitly upgrades `zlib` and `pip` within the Dockerfile to patch upstream vulnerabilities (OS-level hardening).
- **Multi-Stage Builds:** Optimized the build process to reduce the API image size from **210MB to 173MB** and the Postgres footprint from **649MB to 409MB**.

### 3. Professional Registry Management

- **Dynamic Tagging:** Images are tagged with the unique `Git SHA` rather than the generic `latest` tag, enabling precise versioning and 1-click rollbacks in production environments.
- **GitHub Security Integration:** SARIF reports are automatically uploaded to the GitHub Security tab for centralized vulnerability management.

### 4. Developer Experience

- **Local Parity:** Uses `compose.yaml` and Docker Secrets for local development that mirrors production.
- **Interactive Docs:** FastAPI Swagger UI accessible at `http://localhost:8000/docs`.

### 5. 📈 Performance & Security Metrics

- **Postgres Optimization:** Image footprint reduced by **37%** (649MB → 409MB).
- **FastAPI Optimization:** Image footprint reduced by **18%** (210MB → 173MB).
- **Zero-Trust:** 100% of fixable High/Critical vulnerabilities mitigated at the build stage.

## 🛡 Security Status

All fixable vulnerabilities identified by Trivy are documented in the GitHub Security tab. The pipeline is configured to enforce an **exit-code: 1** on critical issues, preventing insecure code from ever reaching Docker Hub.

## 💻 Local Development

To spin up the full environment (API + Database) locally:

```bash
docker compose up -d --build
```

Ensure you have:

- Docker & Docker Desktop installed
- Git cloned this repo
- Set up **secrets/password.txt** file

Once running, explore the interactive API documentation at:
👉 http://localhost:8000/docs

To tear down the app, run:

```bash
docker compose down
```

# Part 2: Automated AWS Cloud Infrastructure & Continuous Deployment (CD)

![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu_24.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Deployment](https://img.shields.io/badge/Deployment-Automated_EC2-orange?style=for-the-badge)

## 📌 Continuous Deployment (CD) Overview

Part 2 extends the pipeline from a static container build to a fully automated Continuous Deployment engine. Using Infrastructure as Code (IaC), the pipeline dynamically provisions AWS resources and orchestrates the deployment of the hardened FastAPI microservice.

## 🛠 Cloud Infrastructure Stack

- **Provider**: Amazon Web Services (AWS)
- **Infrastructure as Code**: Terraform (Terraform HCP Cloud for state management)
- **Compute**: EC2 (Ubuntu 24.04 LTS)
- **Orchestration**: Docker Compose
- **Configuration Management**: Bash Scripting(User Data)

## 🚀 Key CD Engineering Features

### 1. Infrastructure as Code (IaC) with Terraform

Instead of manual console configuration, the environment is defined in code:

- **Automated Provisioning**: Terraform handles the lifecycle of the EC2 instance and Security Groups.
- **Dynamic AMI Lookup**: Automatically fetches the latest Ubuntu 24.04 image to ensure the base OS is always up-to-date with security patches.
- **State Management**: Integrated with Terraform Cloud to provide a single source of truth and prevent state lock issues.

### 2. Configuration & Provisioning

- **User Data Injection**: The `install-docker.sh` script is injected at boot, ensuring the **instance is "Docker-ready"** without manual intervention.
- **Security Group Hardening**: Strict ingress rules only allow traffic on Port 22 (SSH) for management and Port 8000 for API access.

### 3. Secure SSH Orchestration

The pipeline uses the `appleboy/ssh-action` to bridge the gap between the GitHub Runner and the AWS Cloud:

- **Environment Injection**: Safely passes Docker image URL with the latest `github.sha` tag and database secrets from the GitHub Actions runner to the remote EC2 host.
- **Remote Execution**: Executes `run-docker-app.sh` on the EC2 instance to prune old images and spin up the new stack via Docker Compose.

### 4. Production-Ready Docker Orchestration

The deployment script generates a local `compose.yaml` on the fly for:

- **Zero-Downtime Strategy**: Implements `docker compose down` and `docker compose up -d` to refresh the stack.
- **Secret Management**: Utilizes GitHub and Docker Secrets to handle the PostgreSQL password, ensuring sensitive data never touches environment variables in plain text.
- **Health Checks**: The API service waits for the Postgres container to be `service_healthy` before starting, preventing "Database not found" errors during boot.

## 📈 Deployment Workflow

1. **Terraform Init/Apply**: GitHub Actions initializes Terraform and applies the plan.
2. **IP Extraction**: The public IP of the newly created EC2 is captured as a GitHub Output.
3. **Wait Period**: A 110 second buffer ensures the instance has started up, finished its `User Data` script and is ready for SSH.
4. **Remote Deploy**: The runner SSHs into the instance, creates the necessary directory structure and triggers `docker compose`.

## 🔑 Required GitHub Secrets

To run this pipeline, the following secrets must be configured in your repository:

| Secret                    | Description                                              |
| :------------------------ | :------------------------------------------------------- |
| **TF_API_TOKEN**          | Terraform Cloud API token for state management.          |
| **AWS_ACCESS_KEY_ID**     | AWS IAM user key with EC2/VPC permissions.               |
| **AWS_SECRET_ACCESS_KEY** | AWS IAM user secret.                                     |
| **AWS_PRIVATE_KEY**       | The private `.pem` key content used to SSH into the EC2. |
| **POSTGRES_DB_PASSWORD**  | The production password for the database.                |

## 🔗 Accessing the Application

Once the pipeline completes, you can find the Public IP in the AWS Console or in the Terraform Cloud website on the recent run outputs section or in Github workflows ssh step's details.

- **API Endpoint**: `http://<EC2_PUBLIC_IP>:8000/`
- **Documentation**: `http://<EC2_PUBLIC_IP>:8000/docs`

**Warning**: Running this pipeline will incur AWS costs associated with EC2. Ensure you run `terraform destroy` afterwards if you wish to tear down the infrastructure.

## 💡 Concepts that really clicked for me from this project

Assigning an `env` variable in a Github actions workflow in any scope/level, makes that same env variable accessible directly in the runner's shell for additional use like displaying or using its value.

```yaml
name: Example
on: push
env:
  FRUIT_ONE: avocado
jobs:
  runs-on: ubuntu-latest
  env:
    FRUIT_TWO: mango
  steps:
    - name: Which fruits do I have?
    env:
      FRUIT_THREE: pineapple
    # running the ubuntu runner env variables set in the workflow
    run: echo "I have an $FRUIT_ONE, a $FRUIT_TWO and a $FRUIT_THREE.
```

In the workflow you access the environment variable's value using its context like so: `${{ env.FRUIT_TWO }}` while in the runner's shell you access it like so: `$FRUIT_TWO`; just like in a normal Linux shell.

## 🔧 Errors faced and how I fixed them

1. **Error**:

   ```bash
     ssh.ParsePrivateKey: ssh: no key found
     ssh: handshake failed: ssh: unable to authenticate, attempted methods [none], no supported methods remain
     Error: Process completed with exit code 1.
   ```

   **Fix**: I had an extra `%` at the end of my private key which caused the error. So, I removed it and also had to include a newline at the end of the private key when pasting it into `Github secrets` for it to work.

2. **Error**:

   ```bash
   validating /home/ubuntu/app/compose.yaml: services.python_api.image must be a string
   Process exited with status 1
   Error: Process completed with exit code 1.
   ```

   **Fix**: In the **SSH action step**, I added an `envs` attribute that copies the specified runner's environment variables into the EC2's environment; into the EC2 environment, I copied postgres database password (`MY_POSTGRES_DB_PASSWORD`) and the URL to the docker image (`MY_DOCKER_IMAGE`). This together with adding double quotes around `$MY_DOCKER_IMAGE` in `run-docker-app.sh` script fixed the issue.

3. Due to running multiple branches with numerous git commits and history, I got some git merge errors trying to sync the branches. So, I learnt more about `git merge` and when to use `git rebase` too for a clean linear git history.
