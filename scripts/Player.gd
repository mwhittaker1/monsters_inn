extends Node2D

@export var grid_size: int = 32
@export var step_time: float = 0.12 # seconds per step
var _facing := Vector2.DOWN
@onready var _ray: RayCast2D = $InteractRay

var _moving: bool = false
var _from: Vector2
var _to: Vector2
var _t: float = 0.0

func _snap_to_grid(p: Vector2) -> Vector2:
	return (p / grid_size).floor() * grid_size

func _update_facing(dir: Vector2) -> void:
	if dir != Vector2.ZERO:
		_facing = dir

func _ready() -> void:
	_to = _snap_to_grid(global_position)
	_from = _to
	global_position = _to

	var spr := $Sprite2D
	if spr and spr.texture:
		var sz : Vector2 = spr.texture.get_size()
		if sz.x > 0 and sz.y > 0:
			var s := float(grid_size)
			spr.scale = Vector2(s / sz.x, s / sz.y)

func _physics_process(_delta: float) -> void:  # underscore to silence warning
	if _moving:
		_t += _delta / step_time
		global_position = _from.lerp(_to, _t)
		if _t >= 1.0:
			global_position = _to
			_moving = false
		return

func _try_interact() -> void:
	if _ray.is_colliding():
		var hit := _ray.get_collider()
		if hit and hit.has_method("interact"):
			hit.interact(self)
			return
			
	# Fallback point query at the tile in front (bit index 5 == Layer 6)
	var p := global_position + _facing * float(grid_size)
	var params := PhysicsPointQueryParameters2D.new()
	params.position = p
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = 1 << 5
	var space := get_world_2d().direct_space_state
	for res in space.intersect_point(params, 8):
		var a = res["collider"]   # dynamic (=), not infer (:=)
		if a and a.has_method("interact"):
			a.interact(self)
			return
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_try_interact()


	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_up"):
		dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2.DOWN
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		dir = Vector2.RIGHT

	if dir != Vector2.ZERO and !_moving:  # block re-queue during motion
		_start_step(dir)
		
	_ray.target_position = _facing * float(grid_size)
	_ray.force_raycast_update()

func _start_step(dir: Vector2) -> void:
	_moving = true
	_t = 0.0
	_from = global_position
	_to = (_from / grid_size).floor() * grid_size + dir * grid_size
