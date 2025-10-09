extends Node2D

@export var grid_size: int = 32
@export var step_time: float = 0.12 # seconds per step

var _moving: bool = false
var _from: Vector2
var _to: Vector2
var _t: float = 0.0

func _ready() -> void:
	_from = global_position
	_to = _from

func _physics_process(delta: float) -> void:
	if _moving:
		_t += delta / step_time
		if _t >= 1.0:
			global_position = _to
			_moving = false
			return
	global_position = _from.lerp(_to, _t)

	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector2.RIGHT

	if dir != Vector2.ZERO:
		_start_step(dir)

func _start_step(dir: Vector2) -> void:
	_moving = true
	_t = 0.0
	_from = global_position
	_to = (_from / grid_size).floor() * grid_size + dir * grid_size
