from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth import create_access_token, hash_password, verify_password
from app.database import get_db
from app.models import Player
from app.schemas import PlayerLogin, PlayerRegister, PlayerResponse

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=PlayerResponse, status_code=status.HTTP_201_CREATED)
def register(player_data: PlayerRegister, db: Session = Depends(get_db)) -> PlayerResponse:
    existing_email: Player | None = (
        db.query(Player).filter(Player.email == player_data.email).first()
    )
    if existing_email is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )

    existing_username: Player | None = (
        db.query(Player).filter(Player.username == player_data.username).first()
    )
    if existing_username is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already taken",
        )

    hashed: str = hash_password(player_data.password)
    player = Player(
        email=player_data.email,
        username=player_data.username,
        hashed_password=hashed,
    )
    db.add(player)
    db.commit()
    db.refresh(player)

    token: str = create_access_token(data={"sub": str(player.id)})
    return PlayerResponse(
        id=player.id,
        email=player.email,
        username=player.username,
        token=token,
    )


@router.post("/login", response_model=PlayerResponse)
def login(player_data: PlayerLogin, db: Session = Depends(get_db)) -> PlayerResponse:
    player: Player | None = (
        db.query(Player).filter(Player.email == player_data.email).first()
    )
    if player is None or not verify_password(player_data.password, player.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    token: str = create_access_token(data={"sub": str(player.id)})
    return PlayerResponse(
        id=player.id,
        email=player.email,
        username=player.username,
        token=token,
    )
