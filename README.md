# automated-deployment-pipeline

A `Github Actions CI/CD pipeline` that automatically tests a Python FastAPI web app, builds its Docker image and pushes it to Docker Hub.

How to use the API: navigate to this link when you run the multicontainer app to tinker with the API:

```bash
http://localhost:8000/docs
```

Minify:

- Postgres image from 649.38 MB -> 409.25 MB
- python API image from 210.92 MB -> 173.25 MB

Security hardening:

- Use docker secrets and Github secrets to harden security
- non root user for python api container

Sacrificed a less minimal image to fix a security vulnerability with pip, in the multistage python api dockerfile

All Trivy security vulnerabilities that are fixable are posted in the `Security and quality` GitHub tab.
