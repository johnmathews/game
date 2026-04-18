# Developer Setup

## Prerequisites

| Tool | Version | Purpose |
|---|---|---|
| [Godot](https://godotengine.org/download/) | 4.4 (stable) | Game engine and editor |
| [Python](https://www.python.org/) | 3.13+ | Backend runtime |
| [uv](https://docs.astral.sh/uv/) | latest | Python dependency management |
| [Docker](https://docs.docker.com/get-docker/) | latest | Containerized deployment |
| [Docker Compose](https://docs.docker.com/compose/) | v2+ | Multi-service orchestration |

## Godot (Frontend)

Open the `godot/` directory in the Godot 4.4 editor:

```bash
# From the project root
godot --path godot/ --editor
```

Or launch the Godot editor and use "Import" to open `godot/project.godot`.

The editor is used for visual tasks: tilemap editing, scene layout, UI design, animation. Script logic and tests are managed via code.

### Headless HTML5 Export

To build the web export without the editor:

```bash
mkdir -p godot/build
godot --headless --path godot/ --export-release "HTML5" build/index.html
```

This requires the HTML5 export template to be installed. Install it via the editor (Editor > Manage Export Templates) or download from the Godot website.

## Backend

### Install Dependencies

```bash
cd backend
uv sync
```

This installs all runtime and development dependencies (FastAPI, SQLAlchemy, pytest, coverage, etc.) into a virtual environment managed by `uv`.

### Run the Development Server

```bash
cd backend
uv run uvicorn app.main:app --reload
```

The API server starts on `http://localhost:8000`. The `--reload` flag enables auto-restart on code changes.

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `DATABASE_URL` | `sqlite:///./game.db` | SQLAlchemy database connection string |

## Running Tests

### Backend (pytest)

```bash
cd backend
uv run pytest
```

With coverage:

```bash
cd backend
uv run coverage run -m pytest
uv run coverage report
uv run coverage html    # generates htmlcov/index.html
```

### Godot (GUT)

Tests use the [GUT](https://github.com/bitwes/Gut) (Godot Unit Testing) framework. Test scripts live in `godot/tests/`.

Run tests from the command line:

```bash
godot --headless --path godot/ -s addons/gut/gut_cmdln.gd
```

Or run them from the GUT panel inside the Godot editor.

## Docker

### Build and Run

From the project root:

```bash
docker compose up --build
```

This starts nginx (serving the Godot export and proxying the API) and the FastAPI backend. The game is accessible at `http://localhost` (port 80).

### Stop

```bash
docker compose down
```

### Rebuild After Changes

```bash
docker compose up --build --force-recreate
```

## Linting

### GDScript (gdlint)

Install [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit):

```bash
uv tool install gdtoolkit
```

Lint GDScript files:

```bash
gdlint godot/scripts/
```

Format GDScript files:

```bash
gdformat godot/scripts/
```

### Python (ruff)

Install [ruff](https://docs.astral.sh/ruff/):

```bash
uv tool install ruff
```

Lint Python files:

```bash
ruff check backend/
```

Format Python files:

```bash
ruff format backend/
```

## Project Structure Reference

```
game/
  godot/                  # Godot 4.4 project
    project.godot         # Engine configuration
    scenes/               # .tscn scene files
    scripts/              # .gd script files
      autoload/           # Singleton managers (GameManager, SceneManager, NetworkManager)
      player/             # Player character scripts
      village/            # Village scene scripts
      platformer/         # Platformer level scripts
      ui/                 # UI scripts
    assets/               # Sprites, tilesets, audio
    tests/                # GUT test scripts
  backend/                # Python FastAPI server
    app/                  # Application package
      main.py             # FastAPI app entry point
      database.py         # SQLAlchemy engine and session setup
      routers/            # API route modules
    tests/                # pytest test modules
    pyproject.toml        # Python project config and dependencies
  docs/                   # Project documentation
  journal/                # Development journal entries
  CLAUDE.md               # Claude Code project instructions
```
