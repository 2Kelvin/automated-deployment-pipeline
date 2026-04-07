import os
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

def get_secret(secret_name):
    """Helper to read Docker secrets from the /run/secrets/ directory."""
    try:
        with open(f'/run/secrets/{secret_name}', 'r') as f:
            return f.read().strip()
    except IOError:
        # Fallback for local dev if secrets aren't mounted
        return os.getenv(secret_name.upper())

db_user = 'kelvin'
db_pass = get_secret("db_passwd")
db_name = "my_stock"

SQLALCHEMY_DATABASE_URL = f"postgresql://{db_user}:{db_pass}@postgres/{db_name}"

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()