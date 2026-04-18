extends Node
## Handles multiplayer networking via WebSocket connection to the backend.

signal player_joined(player_data: Dictionary)
signal player_left(player_id: String)
signal player_moved(player_id: String, position: Vector2)

var ws: WebSocketPeer = null
var connected: bool = false
var ws_url: String = ""


func _ready() -> void:
	if OS.has_feature("web"):
		ws_url = "ws://" + JavaScriptBridge.eval("window.location.host") + "/ws"
	else:
		ws_url = "ws://localhost:8000/ws"


func connect_to_server() -> void:
	ws = WebSocketPeer.new()
	ws.connect_to_url(ws_url)


func _process(_delta: float) -> void:
	if ws == null:
		return

	ws.poll()

	match ws.get_ready_state():
		WebSocketPeer.STATE_OPEN:
			if not connected:
				connected = true
			while ws.get_available_packet_count() > 0:
				_handle_message(ws.get_packet().get_string_from_utf8())
		WebSocketPeer.STATE_CLOSED:
			connected = false
			ws = null


func _handle_message(raw: String) -> void:
	var json := JSON.new()
	if json.parse(raw) != OK:
		return

	var data: Dictionary = json.data
	match data.get("type", ""):
		"player_joined":
			player_joined.emit(data.get("player", {}))
		"player_left":
			player_left.emit(data.get("player_id", ""))
		"player_moved":
			player_moved.emit(data.get("player_id", ""), Vector2(
				data.get("x", 0),
				data.get("y", 0)
			))


func send_position(pos: Vector2) -> void:
	if ws and connected:
		ws.send_text(JSON.stringify({
			"type": "move",
			"x": pos.x,
			"y": pos.y,
		}))


func disconnect_from_server() -> void:
	if ws:
		ws.close()
		ws = null
		connected = false
