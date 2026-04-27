# Cloud-Native Microservice Pipeline (Part 1: CI & Hardening)

![CI/CD Pipeline](https://img.shields.io/github/actions/workflow/status/2Kelvin/automated-deployment-pipeline/full-cicd.yaml?label=CI/CD%20Pipeline&style=for-the-badge)
![Trivy Scan](https://img.shields.io/badge/Security-Trivy_Checked-blue?style=for-the-badge)
![Docker Size](https://img.shields.io/badge/Docker_Image_Size-173MB-green?style=for-the-badge)

## 📌 Project Overview

This project demonstrates a production-grade Continuous Integration (CI) pipeline for a containerized Python FastAPI application. It bridges the gap between "code that works" and "code that is ready for the enterprise" by implementing automated quality gates, multi-stage builds and advanced security hardening.

_Note: This is Part 1 of a 2-part series. Part 1 focuses on the CI/Build engine; Part 2 will cover the automated CD/deployment to AWS._

## 🛠 Tech Stack

- **API Framework:** FastAPI (Python 3.13)
- **Database:** PostgreSQL
- **Containerization:** Docker & Docker Compose
- **CI/CD:** GitHub Actions
- **Security:** Trivy (Vulnerability Scanning) & Ruff (Linting)
- **Quality:** Pytest & Multi-stage builds

## 🚀 Key Engineering Features

### 1. Automated Quality Gates

Every push or Pull Request triggers a sequential safety net:

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

_Note: This repository covers Part 1 (CI & Registry). Part 2 will implement the Automated AWS Deployment._

---

## Concepts that really clicked from this project

When you assign an `env` variable in a github actions workflow in any scope/level, that same env variable can be accessed directly in the runner's shell for additional use like displaying or using its value.

```yaml
name: Example
on: push
env:
  FRUIT_ONE: avocado
jobs:
  runs-on: ubuntu-latest
  env:
    FRUIT_TWO: banana
  steps:
    - name: Which fruits do I have?
    env:
      FRUIT_THREE: pineapple
    run: echo "I have an $FRUIT_ONE, a $FRUIT_TWO and a $FRUIT_THREE.
```

In the workflow you access the environment variable's value using its context like so: `env.FRUIT_TWO` while in the runner's shell you access it like so: `$FRUIT_TWO`; just like in a normal shell.

## Errors faced and how I fixed them

1. **Error**:

```bash
  ssh.ParsePrivateKey: ssh: no key found
  ssh: handshake failed: ssh: unable to authenticate, attempted methods [none], no supported methods remain
  Error: Process completed with exit code 1.
```

**Fix**: I had an extra `%` at the end of the key which caused the error. So, I removed it and also had to include a newline at the end of the private key when pasting it into `Github secrets` for it to work.

2. **Error**:

```bash
validating /home/ubuntu/app/compose.yaml: services.python_api.image must be a string
Process exited with status 1
Error: Process completed with exit code 1.
```

**Fix**: In **SSH action step**, I added an `envs` attribute that copies the given runner's environment variables into the EC2's environment; into the EC2 environment I copied postgres database password `MY_POSTGRES_DB_PASSWORD` and the URL to the docker image `MY_DOCKER_IMAGE`, this is what fixed the issue together with adding double quotes around `$MY_DOCKER_IMAGE` in `run-docker-app.sh` script.
