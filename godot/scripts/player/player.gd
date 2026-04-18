extends CharacterBody2D
## Player character for the isometric village. Handles movement and network position updates.

const SPEED: float = 200.0
const POSITION_UPDATE_INTERVAL: float = 0.1

var position_update_timer: float = 0.0


func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()

	velocity = input_dir * SPEED
	move_and_slide()

	# Send position updates over the network periodically
	position_update_timer += delta
	if position_update_timer >= POSITION_UPDATE_INTERVAL:
		position_update_timer = 0.0
		NetworkManager.send_position(global_position)
