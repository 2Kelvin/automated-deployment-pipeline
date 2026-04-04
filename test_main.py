import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from database import Base, get_db
from main import app

# 1. Setup an isolated SQLite database for testing
SQLALCHEMY_DATABASE_URL = "sqlite:///:memory:"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 2. Dependency override: Inject the test database into the app
def override_get_db():
    try:
        db = TestingSessionLocal()
        yield db
    finally:
        db.close()

app.dependency_overrides[get_db] = override_get_db

client = TestClient(app)

@pytest.fixture(autouse=True)
def setup_db():
    # Create tables before each test
    Base.metadata.create_all(bind=engine)
    yield
    # Drop tables after each test to keep them isolated
    Base.metadata.drop_all(bind=engine)

# --- THE TESTS ---

def test_create_item():
    response = client.post(
        "/items/",
        json={"title": "Test Item", "description": "This is a test"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["title"] == "Test Item"
    assert "id" in data

def test_read_items():
    # First, seed an item
    client.post("/items/", json={"title": "Item 1", "description": "Desc 1"})
    
    response = client.get("/items/")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["title"] == "Item 1"

def test_read_item_by_id():
    post_res = client.post("/items/", json={"title": "Specific Item", "description": "Find me"})
    item_id = post_res.json()["id"]

    response = client.get(f"/items/{item_id}")
    assert response.status_code == 200
    assert response.json()["title"] == "Specific Item"

def test_update_item():
    post_res = client.post("/items/", json={"title": "Old Title", "description": "Old Desc"})
    item_id = post_res.json()["id"]

    response = client.put(
        f"/items/{item_id}",
        json={"title": "New Title", "description": "New Desc"}
    )
    assert response.status_code == 200
    assert response.json()["title"] == "New Title"

def test_delete_item():
    post_res = client.post("/items/", json={"title": "To Delete", "description": "Bye"})
    item_id = post_res.json()["id"]

    delete_res = client.delete(f"/items/{item_id}")
    assert delete_res.status_code == 200
    
    # Verify it's gone
    get_res = client.get(f"/items/{item_id}")
    assert get_res.status_code == 404