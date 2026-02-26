extends CharacterBody3D


@export var speed := 40.0
@export var max_bounces := 3

var direction: Vector3
var bounces := 0

const TIME_TO_ARM = .5 # seconds
var armed := false

signal hit_target

func _ready():
	add_to_group("projectiles")
	
	var timer = Timer.new()
	timer.wait_time = TIME_TO_ARM
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_arm_mine)
	
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
	
	if armed:
		# Projectile hit friendly tank
		if collider.is_in_group("friendly"):
			_on_hit_target()
			collider.got_hit.emit()
			return
			
		# Projectile hit enemy tank
		if collider.is_in_group("enemy"):
			_on_hit_target()
			collider.got_hit.emit()
			return
	
	bounce(collision)
	
	
func bounce(collision: KinematicCollision3D) -> void:
	# Reflect direction
	direction = direction.bounce(collision.get_normal())
	
	# Rotate projectile
	look_at(global_position + direction, Vector3.UP)
	
func _on_hit_target():
	queue_free()
	
func _arm_mine():
	armed = true
