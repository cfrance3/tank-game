extends CharacterBody3D

@export var turn_speed := 3.0
@export var turret_turn_speed := 12.0

@onready var hull: Node3D = $Hull
@onready var turret: Node3D = $Cannon
@onready var camera: Camera3D = get_viewport().get_camera_3d()

const SPEED = 8.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity.x = input_dir.x * SPEED
	velocity.z = input_dir.y * SPEED

	handle_turret_aim()
	handle_movement(delta)
	
func handle_movement(delta):
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	
	if input.length() > 0:
		input = input.normalized()
		
		velocity.x = input.x * SPEED
		velocity.z = input.y * SPEED
		
		var target_angle = atan2(input.x, input.y)
		hull.rotation.y = lerp_angle(
			hull.rotation.y,
			target_angle,
			turn_speed * get_physics_process_delta_time()
		)
		
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()
	
func handle_turret_aim():
	var mouse_pos = get_viewport().get_mouse_position()
	
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)
	var ray_end = ray_origin + ray_dir * 1000.0
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	if not result:
		return
		
	var target = result.position
	target.y = turret.global_position.y
	
	turret.look_at(target, Vector3.UP)
	
	
