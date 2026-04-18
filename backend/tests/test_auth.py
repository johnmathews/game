from typing import Any

from fastapi.testclient import TestClient


def test_register_success(client: TestClient) -> None:
    response = client.post(
        "/api/auth/register",
        json={
            "email": "new@example.com",
            "password": "password123",
            "username": "newplayer",
        },
    )
    assert response.status_code == 201
    data: dict[str, Any] = response.json()
    assert data["email"] == "new@example.com"
    assert data["username"] == "newplayer"
    assert "token" in data
    assert "id" in data


def test_register_duplicate_email(
    client: TestClient, registered_player: dict[str, Any]
) -> None:
    response = client.post(
        "/api/auth/register",
        json={
            "email": "test@example.com",
            "password": "anotherpassword",
            "username": "differentuser",
        },
    )
    assert response.status_code == 400
    assert response.json()["detail"] == "Email already registered"


def test_login_success(
    client: TestClient, registered_player: dict[str, Any]
) -> None:
    response = client.post(
        "/api/auth/login",
        json={
            "email": "test@example.com",
            "password": "securepassword123",
        },
    )
    assert response.status_code == 200
    data: dict[str, Any] = response.json()
    assert data["email"] == "test@example.com"
    assert data["username"] == "testplayer"
    assert "token" in data


def test_login_wrong_password(
    client: TestClient, registered_player: dict[str, Any]
) -> None:
    response = client.post(
        "/api/auth/login",
        json={
            "email": "test@example.com",
            "password": "wrongpassword",
        },
    )
    assert response.status_code == 401
    assert response.json()["detail"] == "Invalid email or password"
