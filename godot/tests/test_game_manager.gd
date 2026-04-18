extends GutTest
## Tests for the GameManager autoload's local (non-HTTP) methods.


var game_manager: Node


func before_each() -> void:
	game_manager = load("res://scripts/autoload/game_manager.gd").new()
	add_child_autofree(game_manager)


# ---------- collect_map_piece ----------

func test_collect_map_piece_adds_piece() -> void:
	game_manager.collect_map_piece("piece_a")
	assert_has(game_manager.collected_map_pieces, "piece_a", "Should add piece to collected list")


func test_collect_map_piece_no_duplicate() -> void:
	game_manager.collect_map_piece("piece_a")
	game_manager.collect_map_piece("piece_a")
	assert_eq(game_manager.collected_map_pieces.size(), 1, "Should not add duplicate piece")


func test_collect_map_piece_multiple() -> void:
	game_manager.collect_map_piece("piece_a")
	game_manager.collect_map_piece("piece_b")
	assert_eq(game_manager.collected_map_pieces.size(), 2, "Should collect multiple distinct pieces")
	assert_has(game_manager.collected_map_pieces, "piece_a")
	assert_has(game_manager.collected_map_pieces, "piece_b")


# ---------- visit_building ----------

func test_visit_building_adds_building() -> void:
	game_manager.visit_building("tavern")
	assert_has(game_manager.visited_buildings, "tavern", "Should add building to visited list")


func test_visit_building_no_duplicate() -> void:
	game_manager.visit_building("tavern")
	game_manager.visit_building("tavern")
	assert_eq(game_manager.visited_buildings.size(), 1, "Should not add duplicate building")


func test_visit_building_multiple() -> void:
	game_manager.visit_building("tavern")
	game_manager.visit_building("forge")
	assert_eq(game_manager.visited_buildings.size(), 2, "Should track multiple distinct buildings")
	assert_has(game_manager.visited_buildings, "tavern")
	assert_has(game_manager.visited_buildings, "forge")


# ---------- logout ----------

func test_logout_clears_player() -> void:
	game_manager.current_player = {"username": "tester", "token": "abc123"}
	game_manager.is_logged_in = true
	game_manager.logout()
	assert_eq(game_manager.current_player, {}, "Player dict should be empty after logout")


func test_logout_clears_login_state() -> void:
	game_manager.is_logged_in = true
	game_manager.logout()
	assert_false(game_manager.is_logged_in, "Should not be logged in after logout")


func test_logout_clears_collected_pieces() -> void:
	game_manager.collect_map_piece("piece_a")
	game_manager.collect_map_piece("piece_b")
	game_manager.logout()
	assert_eq(game_manager.collected_map_pieces.size(), 0, "Collected pieces should be empty after logout")


func test_logout_clears_visited_buildings() -> void:
	game_manager.visit_building("tavern")
	game_manager.visit_building("forge")
	game_manager.logout()
	assert_eq(game_manager.visited_buildings.size(), 0, "Visited buildings should be empty after logout")
