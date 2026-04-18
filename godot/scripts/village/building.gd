extends Node2D
## Generic building interior scene with navigation and challenge buttons.

@export var building_name: String = "Building"

@onready var building_label: Label = $BackgroundRect/BuildingLabel
@onready var back_button: Button = $BackgroundRect/ButtonContainer/BackButton
@onready var challenge_button: Button = $BackgroundRect/ButtonContainer/ChallengeButton


func _ready() -> void:
	building_label.text = building_name
	back_button.pressed.connect(_on_back_button_pressed)
	challenge_button.pressed.connect(_on_challenge_button_pressed)
	GameManager.visit_building(building_name)


func _on_back_button_pressed() -> void:
	SceneManager.go_to_village()


func _on_challenge_button_pressed() -> void:
	SceneManager.go_to_platformer("PlatformerLevel")
