extends CharacterBody3D


const SPEED = 8.0

signal got_hit

func _ready() -> void:
	add_to_group("enemy")
	
	got_hit.connect(_on_got_hit)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	
func _on_got_hit() -> void:
	queue_free()
	#TODO: ADD DEATH EFFECTS
