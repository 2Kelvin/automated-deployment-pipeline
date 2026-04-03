FROM python:3.14.3-alpine
WORKDIR /items-api
RUN pip install fastapi uvicorn sqlalchemy psycopg2-binary
COPY *.py ./
CMD [ "uvicorn", "main:app", "--reload" ]