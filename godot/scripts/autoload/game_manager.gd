extends Node
## Global game state manager. Handles player data, saves, and game progression.

signal player_logged_in(username: String)
signal game_saved
signal game_loaded

var current_player: Dictionary = {}
var is_logged_in: bool = false
var api_base_url: String = ""

var collected_map_pieces: Array[String] = []
var visited_buildings: Array[String] = []


func _ready() -> void:
	# Default to same origin for web builds
	if OS.has_feature("web"):
		api_base_url = "/api"
	else:
		api_base_url = "http://localhost:8000/api"


func login(email: String, password: String) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)

	var body := JSON.stringify({"email": email, "password": password})
	var headers := ["Content-Type: application/json"]
	http.request(api_base_url + "/auth/login", headers, HTTPClient.METHOD_POST, body)

	var result: Array = await http.request_completed
	http.queue_free()

	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]

	if response_code == 200:
		var json := JSON.new()
		json.parse(response_body.get_string_from_utf8())
		current_player = json.data
		is_logged_in = true
		player_logged_in.emit(current_player.get("username", ""))
		return {"success": true, "player": current_player}
	else:
		return {"success": false, "error": "Login failed"}


func register(email: String, password: String, username: String) -> Dictionary:
	var http := HTTPRequest.new()
	add_child(http)

	var body := JSON.stringify({
		"email": email,
		"password": password,
		"username": username
	})
	var headers := ["Content-Type: application/json"]
	http.request(api_base_url + "/auth/register", headers, HTTPClient.METHOD_POST, body)

	var result: Array = await http.request_completed
	http.queue_free()

	var response_code: int = result[1]
	var response_body: PackedByteArray = result[3]

	if response_code == 201:
		var json := JSON.new()
		json.parse(response_body.get_string_from_utf8())
		current_player = json.data
		is_logged_in = true
		player_logged_in.emit(current_player.get("username", ""))
		return {"success": true, "player": current_player}
	else:
		return {"success": false, "error": "Registration failed"}


func save_game() -> void:
	if not is_logged_in:
		return

	var save_data := {
		"collected_map_pieces": collected_map_pieces,
		"visited_buildings": visited_buildings,
	}

	var http := HTTPRequest.new()
	add_child(http)

	var body := JSON.stringify(save_data)
	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer " + current_player.get("token", "")
	]
	http.request(api_base_url + "/game/save", headers, HTTPClient.METHOD_POST, body)

	var result: Array = await http.request_completed
	http.queue_free()

	if result[1] == 200:
		game_saved.emit()


func load_game() -> void:
	if not is_logged_in:
		return

	var http := HTTPRequest.new()
	add_child(http)

	var headers := [
		"Authorization: Bearer " + current_player.get("token", "")
	]
	http.request(api_base_url + "/game/load", headers, HTTPClient.METHOD_GET)

	var result: Array = await http.request_completed
	http.queue_free()

	if result[1] == 200:
		var json := JSON.new()
		json.parse(result[3].get_string_from_utf8())
		var data: Dictionary = json.data
		collected_map_pieces.assign(data.get("collected_map_pieces", []))
		visited_buildings.assign(data.get("visited_buildings", []))
		game_loaded.emit()


func collect_map_piece(piece_id: String) -> void:
	if piece_id not in collected_map_pieces:
		collected_map_pieces.append(piece_id)


func visit_building(building_id: String) -> void:
	if building_id not in visited_buildings:
		visited_buildings.append(building_id)


func logout() -> void:
	current_player = {}
	is_logged_in = false
	collected_map_pieces.clear()
	visited_buildings.clear()
