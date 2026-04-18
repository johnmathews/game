import json
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

from app.database import Base, engine
from app.routers import auth, game


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None]:
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(title="Game Backend", version="0.1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(game.router)


# --- WebSocket multiplayer ---

connected_players: dict[str, WebSocket] = {}


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket) -> None:
    await websocket.accept()
    player_id: str | None = None
    try:
        # First message should identify the player
        init_data: dict[str, Any] = await websocket.receive_json()
        player_id = str(init_data.get("player_id", id(websocket)))
        connected_players[player_id] = websocket

        while True:
            data: dict[str, Any] = await websocket.receive_json()
            # Broadcast position updates to all other connected players
            message: str = json.dumps(
                {"player_id": player_id, "type": data.get("type", "position"), **data}
            )
            disconnected: list[str] = []
            for pid, ws in connected_players.items():
                if pid != player_id:
                    try:
                        await ws.send_text(message)
                    except Exception:
                        disconnected.append(pid)
            for pid in disconnected:
                connected_players.pop(pid, None)
    except WebSocketDisconnect:
        pass
    finally:
        if player_id is not None:
            connected_players.pop(player_id, None)
