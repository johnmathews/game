extends Node2D
## Manages the isometric village scene, including building entrance detection.

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D

var player_in_building_entrance: bool = false


func _ready() -> void:
	var entrance: Area2D = $BuildingEntrance
	entrance.body_entered.connect(_on_building_entrance_body_entered)
	entrance.body_exited.connect(_on_building_entrance_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and player_in_building_entrance:
		SceneManager.go_to_building("Building")


func _process(_delta: float) -> void:
	if player:
		camera.position = player.position


func _on_building_entrance_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_building_entrance = true


func _on_building_entrance_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_building_entrance = false
