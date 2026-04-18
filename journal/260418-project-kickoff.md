# Project Kickoff

**Date:** 2026-04-18

## Summary

Started building a browser-based exploration game for Vienna (10) and Atlas (7). The game is set in Spaarndam, the village where we live. Players explore an isometric village, enter buildings, and complete challenges (platformer levels, puzzles) to collect map pieces.

## Decisions

### Engine: Godot 4.4

Evaluated Godot vs Phaser (JavaScript-based game framework).

Chose Godot because:

- Visual scene editor for tilemap painting, UI layout, and animation -- essential since I have no prior game dev experience.
- Built-in isometric tilemap support with dedicated node types (`TileMapLayer`, `IsometricTileSet`).
- GDScript is straightforward to learn and Claude Code can read/write `.gd`, `.tscn`, and `.tres` files as text.
- HTML5 export produces a WASM build that runs in the browser, meeting the web deployment requirement.
- GL Compatibility renderer ensures broad browser support via WebGL.

Phaser would have kept everything in JavaScript/TypeScript, but lacks a visual editor entirely. Building isometric tilemaps and scene layouts in code would be slow and error-prone for a first game project.

### Backend: FastAPI + SQLite

- FastAPI for the API server because I already know Python and FastAPI is async-friendly with built-in WebSocket support.
- SQLite for persistence because the game has two players and minimal write concurrency. No need for PostgreSQL complexity at this scale.
- SQLAlchemy as ORM for clean data modeling and easy migration to PostgreSQL later if needed.
- JWT-based auth using `python-jose` and `passlib` for password hashing.

### Art: Free Asset Packs

Using free asset packs for the initial prototype rather than commissioning or creating custom art. The focus right now is on getting the mechanics working. Art can be replaced or refined later.

### Multiplayer: WebSocket Position Sync

When both kids are playing at the same time, they should see each other walking around the village. Implemented as a simple WebSocket broadcast of player positions through the FastAPI backend. No cooperative gameplay mechanics yet -- just presence.

## MVP Scope

The minimum viable product includes:

1. **Isometric village hub** -- Spaarndam village with walkable paths and at least 3-4 buildings visible.
2. **One enterable building** -- with an interior scene that leads to a platformer level.
3. **One platformer level** -- side-scrolling level with basic obstacles. Completing it awards a map piece.
4. **Player accounts** -- login/register from the main menu. Game state tied to accounts.
5. **Save/load** -- game progress persists between sessions.
6. **Web deployment** -- playable in a browser via Docker Compose on the homeserver.

Out of scope for MVP: multiple buildings with unique interiors, puzzle mini-games, NPC dialogue, story sequences, world map screen, sound/music.

## Tech Stack Summary

| Layer | Technology |
|---|---|
| Game engine | Godot 4.4 |
| Game language | GDScript |
| Export target | HTML5 (WebAssembly) |
| Backend framework | FastAPI |
| Backend language | Python 3.13 |
| Database | SQLite (via SQLAlchemy) |
| Auth | JWT (python-jose) + bcrypt (passlib) |
| Multiplayer | WebSocket (FastAPI native) |
| Deployment | Docker Compose + nginx |
| CI/CD | GitHub Actions -> ghcr.io |
| Dependency management | uv (Python), Godot export templates |

## Next Steps

1. **Find isometric asset packs** -- search itch.io and OpenGameArt for free isometric village tilesets and character sprites that fit together stylistically.
2. **Build the village tilemap** -- use the Godot editor to paint the Spaarndam village layout with the chosen tileset. Place buildings, paths, water, and greenery.
3. **Implement platformer mechanics** -- get the side-scrolling player controller working: movement, gravity, jumping, collision with platforms and hazards.
4. **Set up the backend API** -- implement the `/api/auth/*` and `/api/game/*` endpoints with SQLAlchemy models and JWT auth.
5. **Wire up save/load** -- connect the Godot `GameManager` HTTP calls to the live backend and test round-trip persistence.
6. **Docker Compose setup** -- write Dockerfiles for the backend and nginx, create `docker-compose.yml`, and test the full deployment.
