#!/bin/bash

mkdir ~/app
cd ~/app
mkdir secrets
echo "$MY_POSTGRES_DB_PASSWORD" > secrets/password.txt
cat <<EOF > compose.yaml
services:
  postgres:
    image: postgres:18.3-alpine
    expose:
      - 5432
    environment:
      POSTGRES_DB: my_stock
      POSTGRES_USER: kev
      POSTGRES_PASSWORD_FILE: /run/secrets/db_passwd
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U kev -d my_stock"]
      interval: 5s
      timeout: 5s
      retries: 5
    volumes:
      - my_stock:/var/lib/postgresql
    secrets:
      - db_passwd

  python_api:
    depends_on:
      postgres:
        condition: service_healthy
    image: "$MY_DOCKER_IMAGE"
    ports:
      - "8000:8000"
    secrets:
      - db_passwd

secrets:
  db_passwd:
    file: secrets/password.txt

volumes:
  my_stock:
EOF

docker compose up -d
