from collections.abc import Generator
from typing import Any

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.database import Base, get_db
from app.main import app

engine = create_engine(
    "sqlite://",
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)
TestingSessionLocal: sessionmaker[Session] = sessionmaker(
    autocommit=False, autoflush=False, bind=engine
)


@pytest.fixture(autouse=True)
def test_db() -> Generator[Session, Any]:
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:

        def override_get_db() -> Generator[Session, Any]:
            try:
                yield db
            finally:
                pass

        app.dependency_overrides[get_db] = override_get_db
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)
        app.dependency_overrides.clear()


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)


@pytest.fixture
def registered_player(client: TestClient) -> dict[str, Any]:
    response = client.post(
        "/api/auth/register",
        json={
            "email": "test@example.com",
            "password": "securepassword123",
            "username": "testplayer",
        },
    )
    assert response.status_code == 201
    data: dict[str, Any] = response.json()
    return data
