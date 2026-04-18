extends Node2D
## Manages a platformer level, detecting when the player reaches the goal.

@onready var goal: Area2D = $Goal
@onready var player: CharacterBody2D = $PlatformerPlayer

var level_completed: bool = false


func _ready() -> void:
	goal.body_entered.connect(_on_goal_body_entered)


func _on_goal_body_entered(body: Node2D) -> void:
	if body == player and not level_completed:
		level_completed = true
		GameManager.collect_map_piece("platformer_level_1")
		SceneManager.go_to_village()
