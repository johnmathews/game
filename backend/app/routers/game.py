import json
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth import get_current_player
from app.database import get_db
from app.models import GameSave, Player
from app.schemas import GameSaveRequest, GameSaveResponse

router = APIRouter(prefix="/api/game", tags=["game"])


@router.post("/save", response_model=GameSaveResponse)
def save_game(
    save_request: GameSaveRequest,
    player: Player = Depends(get_current_player),
    db: Session = Depends(get_db),
) -> GameSaveResponse:
    save_dict: dict[str, Any] = save_request.model_dump()
    save_json: str = json.dumps(save_dict)

    existing_save: GameSave | None = (
        db.query(GameSave).filter(GameSave.player_id == player.id).first()
    )

    if existing_save is not None:
        existing_save.save_data = save_json
        db.commit()
        db.refresh(existing_save)
        return GameSaveResponse(
            save_data=json.loads(existing_save.save_data),
            updated_at=existing_save.updated_at,
        )

    new_save = GameSave(
        player_id=player.id,
        save_data=save_json,
    )
    db.add(new_save)
    db.commit()
    db.refresh(new_save)
    return GameSaveResponse(
        save_data=json.loads(new_save.save_data),
        updated_at=new_save.updated_at,
    )


@router.get("/load", response_model=GameSaveResponse)
def load_game(
    player: Player = Depends(get_current_player),
    db: Session = Depends(get_db),
) -> GameSaveResponse:
    save: GameSave | None = (
        db.query(GameSave).filter(GameSave.player_id == player.id).first()
    )
    if save is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No save data found",
        )
    return GameSaveResponse(
        save_data=json.loads(save.save_data),
        updated_at=save.updated_at,
    )
