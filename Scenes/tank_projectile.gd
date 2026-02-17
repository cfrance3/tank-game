extends CharacterBody3D


@export var speed := 40.0
@export var max_bounces := 3

var direction: Vector3
var bounces := 0

signal hit_target

func _ready():
	add_to_group("projectiles")
	
	# Forward is -Z
	direction = -global_transform.basis.z
	
	hit_target.connect(_on_hit_target)

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	var collision = move_and_collide(velocity*delta)
	
	if collision:
		handle_collision(collision)

func handle_collision(collision: KinematicCollision3D) -> void:
	bounces += 1
	if bounces > max_bounces:
		queue_free()
		return
		
	var collider = collision.get_collider()
	
	# Projectile hit friendly tank
	if collider.is_in_group("friendly"):
		_on_hit_target()
		#TODO: Add tank death
		return
		
	# TODO: Projectile hit enemy tank
	
	bounce(collision)
	
	
func bounce(collision: KinematicCollision3D) -> void:
	# Reflect direction
	direction = direction.bounce(collision.get_normal())
	
	# Rotate projectile
	look_at(global_position + direction, Vector3.UP)
	
func _on_hit_target():
	queue_free()
