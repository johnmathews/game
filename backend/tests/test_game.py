from typing import Any

from fastapi.testclient import TestClient


def test_save_game(
    client: TestClient, registered_player: dict[str, Any]
) -> None:
    token: str = registered_player["token"]
    response = client.post(
        "/api/game/save",
        json={
            "collected_map_pieces": ["piece_a", "piece_b"],
            "visited_buildings": ["tavern"],
        },
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    data: dict[str, Any] = response.json()
    assert data["save_data"]["collected_map_pieces"] == ["piece_a", "piece_b"]
    assert data["save_data"]["visited_buildings"] == ["tavern"]
    assert "updated_at" in data


def test_load_game(
    client: TestClient, registered_player: dict[str, Any]
) -> None:
    token: str = registered_player["token"]
    # Save first
    client.post(
        "/api/game/save",
        json={
            "collected_map_pieces": ["piece_c"],
            "visited_buildings": ["castle", "library"],
        },
        headers={"Authorization": f"Bearer {token}"},
    )
    # Load
    response = client.get(
        "/api/game/load",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 200
    data: dict[str, Any] = response.json()
    assert data["save_data"]["collected_map_pieces"] == ["piece_c"]
    assert data["save_data"]["visited_buildings"] == ["castle", "library"]


def test_save_requires_auth(client: TestClient) -> None:
    response = client.post(
        "/api/game/save",
        json={
            "collected_map_pieces": [],
            "visited_buildings": [],
        },
    )
    assert response.status_code == 401


def test_load_empty(
    client: TestClient, registered_player: dict[str, Any]
) -> None:
    token: str = registered_player["token"]
    response = client.get(
        "/api/game/load",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert response.status_code == 404
    assert response.json()["detail"] == "No save data found"
