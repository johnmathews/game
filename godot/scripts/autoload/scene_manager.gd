extends Node
## Manages scene transitions with optional fade effects.

signal scene_changed(scene_name: String)

var current_scene_name: String = ""

@onready var tree: SceneTree = get_tree()


func change_scene(scene_path: String) -> void:
	current_scene_name = scene_path.get_file().get_basename()
	tree.change_scene_to_file(scene_path)
	scene_changed.emit(current_scene_name)


func go_to_village() -> void:
	change_scene("res://scenes/village/Village.tscn")


func go_to_building(building_scene: String) -> void:
	change_scene("res://scenes/buildings/" + building_scene + ".tscn")


func go_to_platformer(level_name: String) -> void:
	change_scene("res://scenes/platformer/" + level_name + ".tscn")


func go_to_main_menu() -> void:
	change_scene("res://scenes/ui/MainMenu.tscn")
