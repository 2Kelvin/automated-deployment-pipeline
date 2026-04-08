# automated-deployment-pipeline

A Python FastAPI web service that automatically tests, builds and deploys to a local VM using GitHub Actions and Docker


How to use the API, navigate to this link when you run the multicontainer app:
```bash
http://localhost:8000/docs
```

Minify:

- Postgres image from 649.38 mb -> 409.25mb
- python API image from 210.92 mb -> 150.06mb

Security hardening:

- Use docker secrets and Github secrets to harden security
- non root user for python api container