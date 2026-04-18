# Gameplay Design

## Game Concept

Spaarndam is an exploration game set in a fictional version of the village of Spaarndam in the Netherlands, where the family lives. Players navigate an isometric village, enter buildings, and complete challenges inside them. Challenges range from 2D platformer levels to puzzle mini-games. Completing challenges earns map pieces that unlock new areas and advance the story.

The overarching goal is to explore the world, help people from different countries who are stuck or facing challenges, and collect map pieces that reveal new destinations.

## Target Audience

- **Vienna** (age 10) -- primary player. Comfortable with keyboard controls, can read instructions, enjoys challenge and story progression.
- **Atlas** (age 7) -- secondary player. Enjoys reading and games. Gameplay needs to be accessible at this age: clear visual cues, forgiving mechanics, no time-critical reading.

Design implications:

- Controls must be simple and consistent across all scene types.
- Text should be short and readable. Use visual indicators alongside text where possible.
- Difficulty should be adjustable or self-balancing (early challenges are easy, later ones are harder).
- Death/failure should not be punishing -- quick respawn, no lost progress.

## Player Progression

### Map Pieces

The core progression mechanic is map piece collection. Each completed challenge rewards the player with a map piece. Collected pieces assemble into a world map that reveals new locations or story elements.

Progression state tracked per player:

- `collected_map_pieces` -- list of piece IDs the player has earned
- `visited_buildings` -- list of building IDs the player has entered

This state is saved to the backend and persists across sessions and devices.

### Flow

1. Player logs in or creates an account from the main menu.
2. Saved game state loads automatically.
3. Player appears in the Spaarndam village hub.
4. Player walks around the isometric village and approaches buildings.
5. Interacting with a building entrance transitions to that building's interior scene.
6. Inside, the player faces a challenge (platformer level, puzzle, shop menu, etc.).
7. Completing the challenge awards a map piece and returns the player to the village.
8. Progress saves automatically after each map piece collection.

## Scene Types

### Isometric Village Hub

The main gameplay scene. Top-down isometric view of Spaarndam village.

- Player character moves in 8 directions on the isometric grid.
- Buildings have interaction zones near their entrances.
- NPCs can appear in the village with speech bubbles or quest markers.
- Other online players are visible and move in real time (multiplayer).
- Camera follows the player character.

### Building Interiors

Transitional scenes inside buildings. Each building has its own interior layout.

Examples:

- **Shop:** Menu-based interface where the player can browse items and make choices.
- **Quest giver:** NPC dialogue that sets up a challenge or story beat.
- **Challenge entrance:** Doorway or portal that leads to a platformer level or mini-game.

### 2D Platformer Mini-Games

Side-scrolling platformer levels with a dedicated player controller.

- Horizontal movement with gravity and jumping.
- Obstacles to avoid (gaps, moving platforms, hazards).
- Enemies to defeat or evade.
- A goal at the end of the level that awards a map piece.
- Quick respawn on failure (restart from the level beginning or a checkpoint).

### Future Scene Types

The game is designed to be extensible. Planned or possible scene types:

- Puzzle rooms (logic, pattern matching, memory games)
- Dialogue/story sequences
- Overworld map showing collected pieces and unlocked regions

## Controls

All controls are keyboard-based. The same keys work across all scene types where applicable.

| Action | Keys | Village Hub | Platformer | Menus |
|---|---|---|---|---|
| Move up | W / Up Arrow | Walk north-east | -- | Navigate up |
| Move down | S / Down Arrow | Walk south-west | -- | Navigate down |
| Move left | A / Left Arrow | Walk north-west | Walk left | -- |
| Move right | D / Right Arrow | Walk south-east | Walk right | -- |
| Interact | E / Enter | Enter building, talk to NPC | -- | Confirm selection |
| Jump | Space | -- | Jump | -- |
| Pause | Escape | Open pause menu | Open pause menu | Close menu |

In platformer scenes, up/down movement keys are not used for walking. Jump is only active in platformer scenes.

## Multiplayer

When two or more players are logged in simultaneously, they can see each other's characters moving in the isometric village hub.

### How It Works

1. On entering the village scene, the Godot client connects to the backend via WebSocket (`/ws`).
2. The client sends its position to the server whenever the player moves.
3. The server broadcasts position updates to all other connected clients.
4. Each client renders other players as sprite characters at their reported positions.
5. When a player disconnects or leaves the village, the server notifies remaining clients to remove that player's sprite.

### Scope

- Multiplayer is village-only. Building interiors and platformer levels are single-player.
- There is no chat, trading, or cooperative gameplay in the MVP. Players simply see each other moving around.
- The system is designed for 2 simultaneous players (Vienna and Atlas) but can support more.

### Offline Play

The game works fully offline (without multiplayer features). If the WebSocket connection fails or is unavailable, the player can still explore the village, enter buildings, and complete challenges. Saves still work via HTTP.
