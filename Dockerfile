FROM python:3.14.3-alpine AS building_phase
WORKDIR /python-build
# fix Trivy security vulnerablity: pip outdated; upgrading to pip 26.0
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir --prefix=/app-packages fastapi uvicorn sqlalchemy psycopg2-binary

FROM python:3.14.3-alpine AS polished_app
WORKDIR /python-fast-api
COPY --from=building_phase /app-packages /usr/local
COPY *.py ./
# create a non root user to run the app to harden security
# -D: no password prompt and login. -H: no home directory
RUN adduser -DH kev && chown -R kev:kev /python-fast-api
USER kev
# 0.0.0.0 -> make api container accessible outside and listen to requests from outside (other than itself)
CMD [ "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000" ]