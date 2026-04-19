# 2026-04-19 — Vienna builds the village scene

## What happened

Vienna (age 10) hand-painted the Spaarndam village scene in the Godot editor using the isometric tilesets. This is the first player-facing content in the game.

## Changes made

- **Ground layer**: Painted roads, grass, water, and paths using the ground tileset. Scaled to 2x for better visual size.
- **Buildings layer**: Placed buildings around the village to form streets and neighborhoods.
- **Player position**: Moved start position to (1050, 706) within the village.
- Godot auto-upgraded the scene format from 3 to 4 and added uid:// references to resources.

## Significance

First collaborative contribution to the codebase from one of the target players. The village now has a real hand-crafted layout instead of empty placeholder layers.

## Next steps

- Get player movement working in the village (test with Play button)
- Wire up building entrance detection so entering a building loads the platformer
- Set up the platformer level with real Kenney pixel sprites
- Connect the main menu login flow to the backend
- Test the full loop: login -> village -> enter building -> platformer -> collect map piece -> return to village
