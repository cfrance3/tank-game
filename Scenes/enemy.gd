extends CharacterBody3D

@export var turn_speed := 4.0

@onready var hull: Node3D = $Hull
@onready var turret: Node3D = $Cannon

const SPEED = 10.0

signal got_hit

func _ready() -> void:
	add_to_group("enemy")
	got_hit.connect(_on_got_hit)
	print(-transform.basis.z)

func _physics_process(delta: float) -> void:
	
	_handle_movement(delta)
	
func _handle_movement(delta):
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if input.length() > 0:
		input = input.normalized()
		
		var target_angle = atan2(input.x, input.y)
		var current_angle = hull.global_rotation.y
		var angle_diff = wrapf(target_angle - current_angle, -PI, PI)
		
		var flip_threshold = deg_to_rad(110)
		
		if abs(angle_diff) > flip_threshold:
			angle_diff = wrap(angle_diff - sign(angle_diff) * PI, -PI, PI)
			
		hull.rotation.y += clamp(angle_diff, -turn_speed * delta, turn_speed * delta)
		$Hitbox.rotation.y = hull.rotation.y
		
		var forward = -hull.global_transform.basis.z.normalized()
		var move_dir = Vector3(input.x, 0, input.y).normalized()
		var alignment = forward.dot(move_dir)
		
		var speed_multiplier = abs(alignment)
		speed_multiplier = lerp(0.00, 1.0, speed_multiplier)
		
		velocity = move_dir * SPEED * speed_multiplier
		
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()
	
func _on_got_hit() -> void:
	queue_free()
	#TODO: ADD DEATH EFFECTS
