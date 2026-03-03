extends CharacterBody3D

@export var turn_speed := 4.0

@export var projectile_scene: PackedScene
@export var mine_scene : PackedScene
@export var smoke_scene : PackedScene

@onready var camera: Camera3D = get_viewport().get_camera_3d()
@onready var hull: Node3D = $Hull
@onready var turret: Node3D = $Cannon
@onready var barrel: Marker3D = $Cannon/Barrel
@onready var mine_layer : Marker3D = $Hull/MineLayer

const SPEED = 10.0

var mines_left := 3
var frozen := false

signal got_hit

func _ready() -> void:
	# Add to friendly group to handle projectile collision
	add_to_group("friendly", true)
	
	# Connect body entering area to function
	$Hitbox.body_entered.connect(_on_body_entered)
	
	got_hit.connect(_on_got_hit)

func _physics_process(delta: float) -> void:
	if not frozen:
		_handle_turret_aim()
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
		
		var forward = -hull.transform.basis.z.normalized()
		var move_dir = Vector3(input.x, 0, input.y).normalized()
		var alignment = forward.dot(move_dir)
		
		var speed_multiplier = abs(alignment)
		speed_multiplier = lerp(0.00, 1.0, speed_multiplier)
		
		velocity = move_dir * SPEED * speed_multiplier
		
	else:
		velocity.x = 0
		velocity.z = 0
		
	move_and_slide()
	
func _handle_turret_aim():
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
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and not frozen:
			shoot()
		
	if Input.is_action_just_pressed("ui_accept"):
		_lay_mine()
			
func shoot():
	if projectile_scene == null:
		return
	
	var projectile = projectile_scene.instantiate()
	
	#Position & rotation
	projectile.global_transform = barrel.global_transform
	
	get_tree().current_scene.add_child(projectile)
	
func _lay_mine() -> bool:
	if !(mines_left > 0):
		return false
	if mine_scene == null:
		return false
	
	var mine = mine_scene.instantiate()
	
	get_tree().current_scene.add_child(mine)
	
	mine.global_position = mine_layer.global_position
	mines_left -= 1
	
	return true
	
	

func _on_body_entered(body):
	if body.is_in_group("projectiles"):
		if body.armed:
			_on_got_hit()
			body.hit_target.emit()
		
		
func _on_got_hit() -> void:
	if not frozen:
		_play_smoke_effect()
		frozen = true
	#TODO: ADD DEATH EFFECTS
	
func _play_smoke_effect() -> void:
	var smoke = smoke_scene.instantiate()
	
	get_tree().current_scene.add_child(smoke)
	smoke.global_position = self.global_position
	smoke.start()
