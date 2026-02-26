extends Area3D

const TIME_TO_ARM = 1.0 # seconds

var armed := false

@export var explosion_effect : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = TIME_TO_ARM
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_arm_mine)
	
	add_to_group("mines")
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body) -> void:
	if body.is_in_group("friendly") or body.is_in_group("enemy"):
		if armed:
			body.got_hit.emit()
			_explode()
	
func _explode() -> void:
	_play_explosion_effect()
	queue_free()
	
func _arm_mine() -> void:
	armed = true
	check_current_overlaps_and_explode()
	
func check_current_overlaps_and_explode():
	for body in get_overlapping_bodies():
		if body.is_in_group("friendly") or body.is_in_group("enemy"):
			body.got_hit.emit()
			_explode()
			
func _play_explosion_effect() -> void:
	var explosion = explosion_effect.instantiate()
	
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position
	explosion._explode()
	
