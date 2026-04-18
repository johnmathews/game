extends CharacterBody2D
## Side-scrolling platformer player with gravity and jumping.

const SPEED: float = 300.0
const JUMP_VELOCITY: float = -400.0
const GRAVITY: float = 980.0


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * SPEED

	move_and_slide()
