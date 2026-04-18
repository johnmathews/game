# Architecture

## System Overview

Spaarndam is a browser-based game built with Godot 4.4 (exported as HTML5/WebAssembly) and a Python FastAPI backend for authentication, game saves, and multiplayer state. Game data is persisted in SQLite via SQLAlchemy. The entire stack runs as a Docker Compose deployment on a homeserver (Proxmox, AMD Ryzen 5 PRO 4655G, 62GB RAM).

Players load the game in a web browser. The browser runs the Godot WASM build, which communicates with the backend over HTTP (for auth and saves) and WebSocket (for real-time multiplayer).

## Component Diagram

```
Browser
  |
  v
Godot WASM (HTML5 export)
  |
  |-- HTTP requests ---> nginx ---> FastAPI  ---> SQLite (game.db)
  |                        |
  |-- WebSocket ---------->|------> FastAPI /ws endpoint
  |
nginx also serves static Godot export files (index.html, .wasm, .pck)
```

All traffic flows through a single nginx reverse proxy:

- Static requests (`/`, `/index.html`, `/*.wasm`, `/*.pck`) serve the Godot HTML5 export.
- API requests (`/api/*`) proxy to the FastAPI backend on port 8000.
- WebSocket connections (`/ws`) proxy to the FastAPI WebSocket endpoint.

## Godot Project Structure

```
godot/
  project.godot              # Engine config, autoloads, input mappings
  icon.svg                   # App icon
  scenes/
    ui/
      MainMenu.tscn          # Login/register screen, entry point
    village/
      Village.tscn            # Isometric village hub (main gameplay scene)
    buildings/
      *.tscn                  # Interior scenes for each enterable building
    platformer/
      *.tscn                  # 2D platformer mini-game levels
  scripts/
    autoload/
      game_manager.gd        # Global state: login, save/load, progression tracking
      scene_manager.gd       # Scene transitions (village, buildings, platformer, menu)
      network_manager.gd     # WebSocket client for multiplayer position sync
    player/
      player.gd              # Player character movement and interaction
    village/
      village.gd             # Village scene logic
      building.gd            # Building interaction zones
    platformer/
      platformer_level.gd    # Platformer level logic
      platformer_player.gd   # Platformer-specific player controller
    ui/
      main_menu.gd           # Login/register UI logic
  assets/
    (sprites, tilesets, audio)
  tests/
    (GUT test scripts)
```

### Autoloads

Three singletons are registered in `project.godot` and available globally:

| Autoload | Script | Responsibility |
|---|---|---|
| `GameManager` | `game_manager.gd` | Player authentication, save/load via HTTP, game progression (map pieces, visited buildings) |
| `SceneManager` | `scene_manager.gd` | Scene transitions between village, buildings, platformer levels, and menu |
| `NetworkManager` | `network_manager.gd` | WebSocket connection for real-time multiplayer position broadcasting |

### Rendering

- Renderer: GL Compatibility (for broad browser support via WebGL)
- Viewport: 1280x720 with `canvas_items` stretch mode and `expand` aspect ratio

### Input Map

Actions defined in `project.godot`:

| Action | Keys |
|---|---|
| `move_up` | W, Up Arrow |
| `move_down` | S, Down Arrow |
| `move_left` | A, Left Arrow |
| `move_right` | D, Right Arrow |
| `interact` | E, Enter |
| `jump` | Space |
| `pause_menu` | Escape |

## Backend

### Stack

- **Framework:** FastAPI
- **Database:** SQLite via SQLAlchemy (ORM with `DeclarativeBase`)
- **Auth:** `passlib` (bcrypt hashing), `python-jose` (JWT tokens)
- **WebSocket:** `websockets` library, handled through FastAPI's WebSocket support
- **ASGI server:** Uvicorn

### API Endpoints

#### Authentication

| Method | Path | Description | Request Body | Response |
|---|---|---|---|---|
| POST | `/api/auth/register` | Create a new player account | `{email, password, username}` | `201` with player data + JWT |
| POST | `/api/auth/login` | Log in with existing account | `{email, password}` | `200` with player data + JWT |

#### Game State

All game endpoints require `Authorization: Bearer <token>` header.

| Method | Path | Description | Request Body | Response |
|---|---|---|---|---|
| POST | `/api/game/save` | Save current game state | `{collected_map_pieces, visited_buildings}` | `200` |
| GET | `/api/game/load` | Load saved game state | -- | `200` with `{collected_map_pieces, visited_buildings}` |

#### Multiplayer

| Protocol | Path | Description |
|---|---|---|
| WebSocket | `/ws` | Real-time position sync between connected players |

WebSocket message types:

- **Client sends:** `{"type": "move", "x": float, "y": float}` -- player position update
- **Server broadcasts:** `{"type": "player_joined", "player": {...}}` -- new player connected
- **Server broadcasts:** `{"type": "player_left", "player_id": "..."}` -- player disconnected
- **Server broadcasts:** `{"type": "player_moved", "player_id": "...", "x": float, "y": float}` -- another player moved

### Database

SQLite file stored at `./game.db` (configurable via `DATABASE_URL` environment variable). The `check_same_thread=False` flag is set for compatibility with FastAPI's async request handling.

## Deployment

### Docker Compose

The production deployment uses Docker Compose with three services:

| Service | Image | Role |
|---|---|---|
| `nginx` | `nginx:alpine` | Reverse proxy, serves static Godot export, proxies API and WebSocket |
| `backend` | Custom (Python 3.13 + uv) | FastAPI application server |
| `godot-export` | Build stage only | Exports Godot project to HTML5, copies output to nginx volume |

### nginx Configuration

```
/ .............. Serves Godot HTML5 export (index.html, .wasm, .pck)
/api/* ......... Proxy to backend:8000
/ws ............ WebSocket proxy to backend:8000
```

### CI/CD

GitHub Actions workflow triggers on push to `main`:

1. Builds the Docker image for the backend.
2. Authenticates with `GITHUB_TOKEN`.
3. Pushes to `ghcr.io/johnmathews/game`.

### Build Process

Godot HTML5 export is performed headless:

```bash
godot --headless --export-release "HTML5" build/index.html
```

This produces `index.html`, `index.wasm`, `index.pck`, and supporting files that nginx serves as static content.
