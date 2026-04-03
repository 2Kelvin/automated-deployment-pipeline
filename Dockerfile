FROM python:3.14.3-alpine
WORKDIR /items-api
RUN pip install fastapi uvicorn sqlalchemy psycopg2-binary
COPY *.py ./
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload" ]
# 0.0.0.0 -> make api container accessible outside and listen to requests from outside (other than itself)