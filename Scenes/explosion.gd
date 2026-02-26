extends Node3D

@onready var debris = $Debris
@onready var smoke = $Smoke
@onready var fire = $Fire
@onready var explosion_sound = $ExplosionSound

func _ready() -> void:
	_explode()
	
	
func _explode() -> void:
	debris.restart()
	fire.restart()
	smoke.restart()
	
	debris.emitting = true
	fire.emitting = true
	smoke.emitting = true
	explosion_sound.play()
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
