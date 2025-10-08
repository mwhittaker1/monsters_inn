extends Node2D

@export var role: String = "Bellhop"
@export var speed: float = 120.0
@export var success_rate: float = 0.85

var target: Node2D = null

func _physics_process(delta: float) -> void:
	if target:
		var dir := (target.global_position - global_position)
	if dir.length() > 4.0:
		global_position += dir.normalized() * speed * delta
