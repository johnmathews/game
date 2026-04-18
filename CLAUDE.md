# Spaarndam Game

A browser-based game for John's children, built with Godot 4.4 and hosted on a homeserver.

## Project Overview

An exploration game combining isometric village navigation with 2D mini-games inside buildings. Set in Spaarndam, the
village where the family lives. Players explore the village, enter buildings, and complete challenges to earn map pieces
and progress through the story.

## Players

- **Vienna** (daughter, age 10) — primary player
- **Atlas** (son, age 7) — enjoys reading and games
- Multiplayer: flexible, start with 2 players, design for more later
- Gameplay should be accessible to a 7-year-old but engaging for a 10-year-old

## Tech Stack

- **Engine:** Godot 4.4 (stable)
- **Language:** GDScript
- **Export:** HTML5 (WebAssembly)
- **Backend:** Python API for saves/multiplayer state
- **Database:** PostgreSQL or SQLite for game state persistence
- **Hosting:** Docker Compose on homeserver (Proxmox, AMD Ryzen 5 PRO 4655G, 62GB RAM)
- **CI/CD:** GitHub Actions — build Docker image, push to ghcr.io

## Project Structure

```
game/
  godot/              # Godot project root
    project.godot
    scenes/           # .tscn scene files
    scripts/          # .gd script files
    assets/           # sprites, audio, tilesets
    tests/            # GUT test scripts
  backend/            # Python API server
  docker-compose.yml
  docs/               # project documentation
  journal/            # development journal entries
```

## Development Workflow

- **Visual work** (tilemaps, UI layout, animations): use the Godot editor
- **Logic, tests, builds, deployment, docs**: Claude Code
- All Godot files are text-based (.tscn, .tres, .gd) and version-controlled in git
- Be careful with .tscn internal resource IDs and uid:// references when editing programmatically

## Conventions

- GDScript style: follow Godot's official GDScript style guide
- Scene naming: PascalCase (e.g., `Village.tscn`, `PlatformerLevel.tscn`)
- Script naming: snake_case matching the node (e.g., `player.gd`, `village.gd`)
- Signals: use Godot's signal system for decoupled communication between scenes
- Tests: use GUT framework, test scripts in `tests/` directory
- Export: headless export via `godot --headless --export-release "HTML5" build/index.html`

## Current MVP Goal

Isometric Spaarndam village that players can walk around, with one enterable building containing a simple mini-game.
