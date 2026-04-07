FROM python:3.14.3-alpine
WORKDIR /items-api
# fix Trivy security vulnerablity: zlib outdated
# RUN apk update && apk upgrade --no-cache
# fix Trivy security vulnerablity: pip outdated; upgrading to pip 26.0
# RUN pip install --no-cache-dir --upgrade pip
RUN pip install fastapi uvicorn sqlalchemy psycopg2-binary
COPY *.py ./
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload" ]
# 0.0.0.0 -> make api container accessible outside and listen to requests from outside (other than itself)