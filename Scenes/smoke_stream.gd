extends Node3D

@onready var smoke = $Smoke
	
	
func start() -> void:
	smoke.restart()
	smoke.emitting = true

func stop() -> void:
	smoke.emitting = false
