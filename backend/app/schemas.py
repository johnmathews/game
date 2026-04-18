from datetime import datetime

from pydantic import BaseModel


class PlayerRegister(BaseModel):
    email: str
    password: str
    username: str


class PlayerLogin(BaseModel):
    email: str
    password: str


class PlayerResponse(BaseModel):
    id: int
    email: str
    username: str
    token: str

    model_config = {"from_attributes": True}


class GameSaveRequest(BaseModel):
    collected_map_pieces: list[str]
    visited_buildings: list[str]


class GameSaveResponse(BaseModel):
    save_data: dict
    updated_at: datetime

    model_config = {"from_attributes": True}
