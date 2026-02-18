extends CharacterBody3D


const SPEED = 8.0

func _ready() -> void:
	add_to_group("enemy")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	move_and_slide()
